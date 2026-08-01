import '../runtime/engine_effect.dart';
import '../state/phone.dart';
import 'command.dart';
import 'command_helpers.dart';

/// Voice / video call flow.
List<CommandHandler> callCommands() => <CommandHandler>[
  const FunctionCommand(<String>['call_incoming'], _incoming),
  const FunctionCommand(<String>['call_start'], _start),
  const FunctionCommand(<String>['call_line'], _line),
  const FunctionCommand(<String>['call_end'], _end),
  const FunctionCommand(<String>['voicemail'], _voicemail),
  const FunctionCommand(<String>['missed_call'], _missed),
];

CommandOutcome _incoming(CommandContext ctx) {
  final String character = ctx.id(0);
  if (character.isEmpty) return CommandOutcome.next;
  ctx.engine.state.ensureCharacter(character);

  final PhoneCall call = PhoneCall(
    id: ctx.uid('call'),
    characterId: character,
    state: CallState.incoming,
    startedAt: ctx.engine.clock.now(),
    video: ctx.namedBool('video'),
  );
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(
      activeCall: call,
      calls: <PhoneCall>[call, ...p.calls],
      locked: false,
    ),
  );
  ctx.engine.emitEffect(
    OpenAppEffect(
      'calls',
      screen: 'incoming',
      arguments: <String, Object?>{'character': character},
    ),
  );
  ctx.engine.emitEffect(
    PlaySoundEffect(ctx.namedStr('ringtone', 'vibrate'), volume: 0.9),
  );
  ctx.engine.emitEffect(const VibrateEffect(milliseconds: 400));
  return CommandOutcome.next;
}

CommandOutcome _start(CommandContext ctx) {
  final String character = ctx.id(0);
  final PhoneCall call = PhoneCall(
    id: ctx.uid('call'),
    characterId: character,
    state: CallState.active,
    startedAt: ctx.engine.clock.now(),
    video: ctx.namedBool('video'),
  );
  ctx.engine.state.updatePhone(
    (PhoneState p) =>
        p.copyWith(activeCall: call, calls: <PhoneCall>[call, ...p.calls]),
  );
  ctx.engine.emitEffect(const OpenAppEffect('calls', screen: 'active'));
  return CommandOutcome.next;
}

/// One spoken line inside an active call.
CommandOutcome _line(CommandContext ctx) {
  final String speaker = ctx.id(0);
  final String text = ctx.str(1);
  if (text.isEmpty) return CommandOutcome.next;

  ctx.engine.state.updatePhone((PhoneState p) {
    final PhoneCall? call = p.activeCall;
    if (call == null) return p;
    return p.copyWith(
      activeCall: call.copyWith(
        transcript: <String>[...call.transcript, '$speaker: $text'],
      ),
    );
  });
  return CommandOutcome.wait(ctx.readingTime(text));
}

CommandOutcome _end(CommandContext ctx) {
  ctx.engine.state.updatePhone((PhoneState p) {
    final PhoneCall? call = p.activeCall;
    if (call == null) return p;
    final PhoneCall ended = call.copyWith(
      state: CallState.ended,
      durationSeconds: ctx.engine.clock
          .now()
          .difference(call.startedAt)
          .inSeconds,
    );
    return p.copyWith(
      activeCall: null,
      calls: p.calls
          .map((PhoneCall c) => c.id == ended.id ? ended : c)
          .toList(),
    );
  });
  ctx.engine.emitEffect(const NavigateEffect('/phone'));
  return CommandOutcome.next;
}

CommandOutcome _voicemail(CommandContext ctx) {
  final String character = ctx.id(0);
  final PhoneCall call = PhoneCall(
    id: ctx.uid('vm'),
    characterId: character,
    state: CallState.voicemail,
    startedAt: ctx.engine.clock.now(),
    durationSeconds: ctx.namedInt('duration', 20),
    transcript: <String>[ctx.str(1)],
  );
  ctx.engine.state.updatePhone(
    (PhoneState p) => p.copyWith(calls: <PhoneCall>[call, ...p.calls]),
  );
  return CommandOutcome.next;
}

CommandOutcome _missed(CommandContext ctx) {
  final String character = ctx.id(0);
  final PhoneCall call = PhoneCall(
    id: ctx.uid('missed'),
    characterId: character,
    state: CallState.missed,
    startedAt: ctx.engine.clock.now(),
  );
  ctx.engine.state.updatePhone(
    (PhoneState p) =>
        p.copyWith(calls: <PhoneCall>[call, ...p.calls], activeCall: null),
  );
  return CommandOutcome.next;
}
