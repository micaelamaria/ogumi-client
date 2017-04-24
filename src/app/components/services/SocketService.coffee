angular.module "webClient"
  .service 'SocketService', ($window) ->

    @stompEntryUrl = ''
    @client = ''
    @socket = ''

    @status = 'disconnected'

    connect: (url, access_token) ->
      return @getClient() if @status == "connected"
      throw new Error ('SocketService: no url given') if !url
      @stompEntryUrl = url
      throw new Error('SocketService: stompEntryUrl has to be set prior calling connect() (use setStompEntryUrl(url))') if !@stompEntryUrl
      @socket = new $window.SockJS(@stompEntryUrl + "?access_token="+access_token)
      @client = $window.Stomp.over(@socket)
      @status = 'connected' if @socket
      @client.debug = null
      @client.connect()
      @getClient()

    disconnect: () ->
      if (@client?)
        @client.disconnect()
        @status = 'disconnected'

    getClient: () ->
      @client

    getSocket: () ->
      @socket
