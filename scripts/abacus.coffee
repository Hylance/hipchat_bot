parser = require "xml2json"

module.exports = (robot) ->
  robot.respond /Status for (.*)/i, (msg) ->
    getABtest msg, msg.match[1]


  options =
    rejectUnauthorized: false
  getABtest = (msg, query) ->
    msg.http("http://abacus-metadata-server.exp-int.net/abacus/abtest/v3/get/experimentdetails?expId=#{query}", options)
      .query(format: 'xml')
      .get() (err, res, body) ->
        if err
          msg.send "Encountered an error :( #{err}"
          return
        if res.statusCode isnt 200
          msg.send "Request didn't come back HTTP 200 :("
          return
        json =  parser.toJson(body)
        data = JSON.parse(json)
        result = "/code "
        experiment = data.GetExperimentAndInstanceDetailsResponse.Experiment
        if experiment is undefined
          msg.send "Sorry, I don't find any AB test match your search"
          return
        Id = "Id: #{query} \n"
        Name = "name: #{experiment.Name} \n"
        groups = []
        Instance = experiment.InstanceList.Instance
        if Instance instanceof Array
          for instance in Instance
            if instance.Status is "Running"
              treatmentGroups = instance.TreatmentGroups.TreatmentGroup
              for treatmentGroup in treatmentGroups
                groups.push({
                  key: treatmentGroup.Description,
                  value: treatmentGroup.Percentage
                })
        else
          if Instance.Status is "Running"
            treatmentGroups = Instance.TreatmentGroups.TreatmentGroup
            for treatmentGroup in treatmentGroups
              groups.push({
                key: treatmentGroup.Description,
                value: treatmentGroup.Percentage
              })
        result = result + Id + Name
        for group in groups
          result = result + "#{group.key} : #{group.value} \n"
        msg.send result
