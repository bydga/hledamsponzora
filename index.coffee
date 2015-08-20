(require "cson-config").load()
async = require "async"
Download = require "download"
request = require "request"
fs = require 'fs'

url = "http://www.hledamsponzora.cz/detail.aspx?c="

run = (next) ->
	async.eachLimit [1..10000], 100, (i, next) ->
		o =
			url: "#{url}#{i}"
			headers:
				cookie: process.config.cookie
			followRedirect: false
		request o, (e, r, b) ->
			return next e if e
			return next() if b.indexOf("person-title page-title blue") >= 0
			return next() if b.indexOf("<title>Object moved</title>") >= 0
			cena = "-"
			if m = b.match /Očekávám (.*?) měsí+/
				cena = m[1]

			mesto = "-"
			if m = b.match /Bydliště<\/td><td>(.*?)</
				mesto = m[1]

			res = b.match /(fotky\/velke\/.*?\.jpg)/g
			return next() unless res
			imgs = res.map (o) -> "http://hledamsponzora.cz/#{o}"
			console.log i, imgs

			watermark = "#{i} - #{cena} - #{mesto}"
			console.log watermark
			d = new Download({mode: '755'})
			d.get(img) for img in imgs
			d.dest("imgs").rename((o) ->
				o.basename = "#{i}-#{o.basename}"
				f = "./imgs/" + o.basename + o.extname + ".txt"
				fs.writeFileSync f, watermark
				console.log o
			).run () ->
				next()
	, (e) ->
		next e



run (e) ->
	console.log e if e
	console.log "done"
	process.exit()
