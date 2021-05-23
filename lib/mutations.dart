final createMessage = r'''
 mutation createmessage($message: String!, $iv: String!) {
  createMessage(input: {message: $message, iv: $iv}) {
    id
  }
}
''';
