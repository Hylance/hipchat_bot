_          = require("underscore")
_s         = require("underscore.string")
Select     = require("soupselect").select
HTMLParser = require "htmlparser"

module.exports = (robot) ->

  robot.hear /expedia/i, (res) ->
    res.send "Expedia? It's a great online travel agency!"

  robot.respond /, what do I look like?/i, (res) ->
    res.send "Shuheng, you are the most handsome man in the world"

  robot.respond /, do you love me?/i, (res) ->
    res.send "Baby, I love you with all my heart."

  robot.respond /, what do you think my demo today?/i, (res) ->
    res.send "People love me, so you are doing a great job!"

  robot.respond /, how are you?/i, (res) ->
    res.send "I am good."

  robot.respond /, what is (.*)/i, (msg) ->
    getTerm msg, msg.match[1]

  options =
    rejectUnauthorized: false
  getTerm = (msg, query) ->
    msg.http("https://dictionary.exp-tools.net/v/#{query}", options)
    .get() (err, res, body) ->
      if err
        msg.send "Encountered an error :( #{err}"
        return
      if res.statusCode isnt 200
        msg.send "Request didn't come back HTTP 200 :("
        return
      paragraphs = parseHTML(body, "p")

      msg.send "Got back #{paragraphs}"


parseHTML = (html, selector) ->
  handler = new HTMLParser.DefaultHandler((() ->),
    ignoreWhitespace: true
  )
  parser  = new HTMLParser.Parser handler
  parser.parseComplete html

  Select handler.dom, selector
