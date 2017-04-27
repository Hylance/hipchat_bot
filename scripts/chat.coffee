module.exports = (robot) ->

  robot.hear /expedia/i, (res) ->
    res.send "Expedia? It's a great online travel agency!"

  robot.respond /, what do I look like?/i, (res) ->
    res.send "Shuheng, you are the most handsome man in the world!"

  robot.respond /, do you love me?/i, (res) ->
    res.send "Baby, I love you with all my heart."

  robot.respond /, what do you think my demo today?/i, (res) ->
    res.send "People love me, so you are doing a great job!"