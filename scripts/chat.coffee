_          = require("underscore")
_s         = require("underscore.string")
Select     = require("soupselect").select
HTMLParser = require "htmlparser"

module.exports = (robot) ->

  robot.hear /expedia/i, (res) ->
    res.send "Expedia? It's a great online travel agency!"

  robot.respond /what does (.*) look like?/i, (res) ->
    if res.match[1].toLowerCase() is "shuheng"
      res.send "#{res.match[1].toLowerCase()} is the most handsome man in the world!"
    else
      res.send "#{res.match[1].toLowerCase()} looks terrible!"

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
      contents = parseHTML(body, ".panel-default")
      if contents.length is 1
        msg.send "Sorry, I don't find anything match your search."
        return
      for item in contents
        header = Select(item, "h3")
        childs = _.flatten childrenOfType(header[0], 'text')
        header_text = (textNode.data for textNode in childs).join ''
        msg.send header_text
        paragraphs = Select(item, "p")
        result = ""
        for paragraph in paragraphs
          text = _.flatten childrenOfType(paragraph, 'text')
          paragraph_text = (textNode.data for textNode in text).join ''
          paragraph_text = paragraph_text + "\n"
          result = result + paragraph_text
        if result != ""
          msg.send "/code " + result


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

