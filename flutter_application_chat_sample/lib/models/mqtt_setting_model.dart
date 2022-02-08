class MqttSettingModel {
  MqttSettingModel({
    this.autoReconnect = true,
    this.clientIdentifier = 'your identifier',
    this.keepAlivePeriod = 43200,
    this.logging = true,
    this.maxConnectionAttempt = 3,
    this.pongCount = 3,
    this.port = 1883,
    this.serverUrl = 'test.mosquitto.org',
    this.authenticateUsername = 'username',
    this.authenticatePassword = 'password',
    this.willTopic = 'willtopic',
    this.willMessage = 'Will message',
    
  });

  String serverUrl = 'test.mosquitto.org';
  String clientIdentifier = 'your identifier';
  bool logging = true;
  int maxConnectionAttempt = 3;
  int pongCount = 0;
  int port = 1883;
  int keepAlivePeriod = 43200;
  bool autoReconnect = true;
  String authenticateUsername = 'username';
  String authenticatePassword = 'password';
  String willTopic = 'willtopic';
  String willMessage = 'Will message';
}
