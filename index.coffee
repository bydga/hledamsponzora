(require "cson-config").load()
async = require "async"
Download = require "download"
request = require "request"


url = "http://www.hledamsponzora.cz/detail.aspx?c="

run = (next) ->
	async.each [1..10000], (i, next) ->
		o =
			url: "#{url}#{i}"
			headers:
				cookie: process.config.cookie
			followRedirect: false
		request o, (e, r, b) ->
			return next e if e
			return next() if b.indexOf("person-title page-title blue") >= 0
			return next() if b.indexOf("<title>Object moved</title>") >= 0
			res = b.match /(fotky\/velke\/.*?\.jpg)/g
			return next() unless res
			imgs = res.map (o) -> "http://hledamsponzora.cz/#{o}"
			console.log i, imgs
			d = new Download({mode: '755'})
			d.get(img) for img in imgs
			d.dest("imgs").rename((o) -> o.basename = "#{i}-#{o.basename}").run () ->
				next()
	, (e) ->
		next e



run (e) ->
	console.log e if e
	console.log "done"
	process.exit()
