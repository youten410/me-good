import 'package:dart_openai/dart_openai.dart';

void main() async {
  final comment = '雨が降り続き、心も曇った1日だった。期待していた予定は全てキャンセル、失意の日が終わる。';
  await getAdvice(comment);
}

Future<void> getAdvice(comment) async {
  OpenAI.apiKey = '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';

  // Start using!
  final completion = await OpenAI.instance.completion.create(
      model: "text-davinci-003",
      prompt:
          '100上記の文にカウンセラー風に日本語でアドバイスをお願いします。文末は「〜ましょう」で終わるようにしてください。文字数は50文字でお願いします。: $comment',
      maxTokens: 200);

  // Printing the output to the console
  String response = completion.choices[0].text;

  print('アドバイス $response');

  // // Generate an image from a prompt.
  final image = await OpenAI.instance.image.create(
    prompt: comment,
    n: 1,
  );

  // // Printing the output to the console.
  String? imageUrl = image.data.first.url;

  print(imageUrl);
}
