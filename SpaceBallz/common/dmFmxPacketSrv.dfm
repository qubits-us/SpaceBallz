object SrvCommsDM: TSrvCommsDM
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 159
  Width = 353
  object srvSock: TWSocketServer
    LineEnd = #13#10
    Port = '9000'
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    ListenBacklog = 15
    OnDataAvailable = srvSockDataAvailable
    OnDataSent = srvSockDataSent
    OnError = srvSockError
    OnBgException = srvSockBgException
    OnSocksError = srvSockSocksError
    SocketErrs = wsErrTech
    onException = srvSockException
    OnClientDisconnect = srvSockClientDisconnect
    OnClientConnect = srvSockClientConnect
    OnClientCreate = srvSockClientCreate
    MultiListenSockets = <>
    Left = 32
    Top = 32
    Banner = ''
    BannerTooBusy = ''
  end
end
