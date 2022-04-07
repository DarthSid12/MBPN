class ApiConfig {
  static String baseUrl = 'https://gbpn.com/api';
  static String login = baseUrl + '/auth';
  static String whoAmI = baseUrl + '/who-am-i';
  static String voicemails = baseUrl + '/voicemail';
  static String getCalls = baseUrl + '/calls';
  static String getCompany = baseUrl + '/select-company';
  static String switchCompany = baseUrl + '/select-company';
  static String sendMessage = baseUrl + '/sms/messages';
  static String newConversation = baseUrl + '/sms/messages';
  static String getMessages = baseUrl + '/sms/conversations';
}
