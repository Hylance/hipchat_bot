_          = require("underscore")
_s         = require("underscore.string")
Select     = require("soupselect").select
HTMLParser = require "htmlparser"

module.exports = (robot) ->

  robot.hear /expedia/i, (res) ->
    res.send "Expedia? It's a great online travel agency!"

  robot.respond /what does (.*) look like?/i, (res) ->
    if res.match[1].toLowerCase() is "shuheng"
      res.send "You are the most handsome man in the world!"
    else
      res.send "You look terrible!"

  robot.respond /do you love me?/i, (res) ->
    res.send "Baby, I love you with all my heart."

  robot.respond /how are you?/i, (res) ->
    res.send "I am good. Thanks for asking."

  robot.respond /what is (.*)/i, (msg) ->
    getTerm msg, msg.match[1].toLowerCase()

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
      header = parseHTML(body, "h3")
      paragraphs = parseHTML(body, "p")
      if header.length is 0
        msg.send "Sorry, I don't find anything match your search."
        return
      childs = _.flatten childrenOfType(header[0], 'text')
      header_text = (textNode.data for textNode in childs).join ''
      msg.send header_text
      paragraph = _.flatten childrenOfType(paragraphs[0], 'text')
      paragraph_text = (textNode.data for textNode in paragraph).join ''
      msg.send "/code " + paragraph_text


parseHTML = (html, selector) ->
  handler = new HTMLParser.DefaultHandler((() ->),
    ignoreWhitespace: true
  )
  parser  = new HTMLParser.Parser handler
  parser.parseComplete html

  Select handler.dom, selector

childrenOfType = (root, nodeType) ->
  return [root] if root?.type is nodeType

  if root?.children?.length > 0
    return (childrenOfType(child, nodeType) for child in root.children)

