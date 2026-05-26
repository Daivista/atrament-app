import 'package:flutter_test/flutter_test.dart';
import 'package:atrament_app/core/network/sse_parser.dart';

void main() {
  group('SseParser', () {
    test('pojedyncza linia data: zwraca payload', () {
      final p = SseParser();
      final e = p.addChunk('data: {"a":1}\n');
      expect(e.length, 1);
      expect(e.first.data, '{"a":1}');
      expect(e.first.isDone, false);
    });

    test('[DONE] ustawia isDone', () {
      final p = SseParser();
      final e = p.addChunk('data: [DONE]\n');
      expect(e.length, 1);
      expect(e.first.isDone, true);
    });

    test('wiele linii w jednym chunku', () {
      final p = SseParser();
      final e = p.addChunk('data: {"x":1}\ndata: {"x":2}\n');
      expect(e.length, 2);
      expect(e[0].data, '{"x":1}');
      expect(e[1].data, '{"x":2}');
    });

    test('linia rozcięta między chunkami (buforowanie)', () {
      final p = SseParser();
      expect(p.addChunk('da').length, 0);
      expect(p.addChunk('ta: hello\n').first.data, 'hello');
    });

    test('JSON rozcięty przez granicę TCP', () {
      final p = SseParser();
      expect(p.addChunk('data: {"content":').length, 0);
      final e = p.addChunk('"hi"}\n');
      expect(e.first.data, '{"content":"hi"}');
    });

    test('komentarz (keepalive) jest ignorowany', () {
      final p = SseParser();
      expect(p.addChunk(': keepalive\n').length, 0);
    });

    test('puste linie (separatory zdarzeń) ignorowane', () {
      final p = SseParser();
      final e = p.addChunk('\n\ndata: {"a":1}\n\n');
      expect(e.length, 1);
    });

    test('obsługa CRLF (\\r\\n)', () {
      final p = SseParser();
      final e = p.addChunk('data: {"a":1}\r\n');
      expect(e.first.data, '{"a":1}');
    });

    test('[DONE] rozcięte między chunkami', () {
      final p = SseParser();
      expect(p.addChunk('data: [DO').length, 0);
      expect(p.addChunk('NE]\n').first.isDone, true);
    });

    test('mieszany strumień: tokeny + DONE w jednym chunku', () {
      final p = SseParser();
      final e = p.addChunk('data: {"t":"a"}\ndata: {"t":"b"}\ndata: [DONE]\n');
      expect(e.length, 3);
      expect(e[0].data, '{"t":"a"}');
      expect(e[2].isDone, true);
    });
  });
}
