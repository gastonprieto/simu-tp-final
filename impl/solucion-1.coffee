'use strict';

_ = require 'lodash'

class Simulation
	constructor: (@Threads, @StaticTimeIndex)->
		@T = 0
		@DoneRequests = 0
		@RequestArrived = 0
		@RejectedRequests = 0

		@TotalThreads = @Threads.length
		@CurrentThreadIndex = 0

	run: (FinalTime, TimeOut)->
		TPLL = 0
		while @T < FinalTime
			@RequestArrived += 1
			assignedThread = @assignThread()
			if assignedThread.commitedTimeFrom(@T) > TimeOut #Reject Request
				@RejectedRequests += 1
			else #Accept request
				@executeRequest assignedThread

			arrivalTime = @getArrivalTime()
			@T += arrivalTime

	executeRequest: (thread) ->
		@DoneRequests += 1
		thread.executeRequest @

	assignThread: ->
		@CurrentThreadIndex += 1
		@Threads[@CurrentThreadIndex % @TotalThreads]

	getAssistanceTime: ->
		staticAttention = ->
			x = Math.random()
			y = Math.pow(1 / Math.pow(x, 3.07759) - 1, 0.51182)
			throw new Error(y)  if isNaN(y) or y < 0
			return y

		dynamicAttention = ->
			x = Math.random()
			y = Math.pow(1 / Math.pow(x, 3.07759) - 1, 0.51182)
			throw new Error(y)  if isNaN(y) or y < 0
			return y + 10000

		if Math.random() < @StaticTimeIndex
			return staticAttention()
		else
			return dynamicAttention()

	getArrivalTime: ->
		x = Math.random()
		y = Math.pow(1 / Math.pow(x, 3.07759) - 1, 0.51182)
		throw new Error(y)  if isNaN(y) or y < 0
		#console.log "ARRIVAL TIME:   " + y + "" if y > 56000
		return y

	printResults: ->
		timeRounded = Math.round @T
		console.log "Time: #{timeRounded}"
		console.log "Done: #{@DoneRequests}"
		console.log "Rejected: #{@RejectedRequests}"
		console.log "Total Arrived: #{@RequestArrived}"

		console.log "Porc Rejecteds: #{@RejectedRequests * 100 / @RequestArrived} %"

class Thread
	constructor: ->
		@CommiedTime = 0
		@IdleTime = 0
		@WaitingToBeginProcess = 0
		@TimeToRespond = 0

	executeRequest: (simulation) ->
		if simulation.T >= @CommiedTime #Idle thread
			@addIdleTime(simulation.T - @CommiedTime)
			@CommiedTime = simulation.T
		else #Commited thread
			@WaitingToBeginProcess += @CommiedTime - simulation.T

		@CommiedTime += simulation.getAssistanceTime()
		@TimeToRespond = @CommiedTime - simulation.T

	addIdleTime: (quantity) ->
		@IdleTime += quantity

	commitedTimeFrom: (time) ->
		@CommiedTime - time

run = ->
	generateThreads = (nThreads)->
		for i in [1..nThreads]
			new Thread()

	msInMonth = 1000 * 60 * 60 * 24 * 30

	nThreads = 200
	timeOut = 50 * 1000
	threads = generateThreads(nThreads)
	simulation = new Simulation threads, 0.8
	simulation.run 12 * msInMonth, timeOut
	simulation.printResults()
	#console.log simulation

run()
