final getMessage = r'''
  query getMessage($id: ID!) {
    getMessage(id: $id) {
      message
      iv
    }
  }
''';
