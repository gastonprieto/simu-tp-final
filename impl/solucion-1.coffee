'use strict';

_ = require 'lodash'

exeded = 0

class Simulation
	constructor: (@Threads, @StaticTimeIndex, @TimeOut)->
		@T = 0
		@DoneRequests = 0
		@RequestArrived = 0
		@RejectedRequests = 0

		@TotalThreads = @Threads.length
		@CurrentThreadIndex = 0

	run: (FinalTime)->
		TPLL = 0
		while @T < FinalTime
			@RequestArrived += 1
			assignedThread = @assignThread()
			if assignedThread.commitedTimeFrom(@T) > @TimeOut #Reject Request
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
		while (res = @_getArrivalTime()) > 80 * 1000 * 1000
			exeded += 1
			#console.log "EXEDED: #{exeded} with value #{res / 1000 * 60 * 60} hours."
		res

	_getArrivalTime: ->
		x = Math.random()
		y = Math.pow(1 / Math.pow(x, 3.07759) - 1, 0.51182)
		throw new Error(y)  if isNaN(y) or y < 0
		return y

	printResults: ->
		timeRounded = Math.round @T
		console.log "Time: #{timeRounded}"
		console.log "Done: #{@DoneRequests}"
		console.log "Rejected: #{@RejectedRequests}"
		console.log "Total Arrived: #{@RequestArrived}"

		console.log "\nPorc Rejecteds: #{@RejectedRequests * 100 / @RequestArrived} %"
		console.log "Porc Idle: #{@_porcIdleTime()} %"
		console.log "Waiting Averange: #{@_waitingAverange()}"
		console.log "Time To Respond Averange: #{@_TimeToRespondAverange()}"

	_porcIdleTime: ->
		total = _.reduce @Threads,((res, val) => res + val.IdleTime), 0
		total * 100 / (@Threads.length * @T)

	_waitingAverange: ->
		total = _.reduce @Threads, ((res, val) => res + val.WaitingToBeginProcess), 0
		total / @DoneRequests

	_TimeToRespondAverange: ->
		total = _.reduce @Threads, ((res, val) => res + val.TimeToRespond), 0
		total / @DoneRequests

class Thread
	constructor: ->
		@CommiedTime = 0
		@IdleTime = 0
		@WaitingToBeginProcess = 0
		@TimeToRespond = 0

	executeRequest: (simulation) ->
		if simulation.T >= @CommiedTime #Idle thread
			@addIdleTime(simulation.T - @CommiedTime)
			@CommiedTime = simulation.T #The request process start now
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

	nThreads = 300
	timeOut = 10 * 1000
	years = 2
	threads = generateThreads nThreads
	simulation = new Simulation threads, 0.8, timeOut
	for i in [1..years]
		simulation.run i * 12 * msInMonth
		console.log "Year #{i} of #{years}completed. And Time is #{simulation.T / msInMonth}."

	simulation.printResults()
	console.log exeded
	#console.log simulation

run()
