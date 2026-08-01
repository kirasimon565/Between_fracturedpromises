import '../engine_defaults.dart';
import '../events/engine_event.dart';
import '../runtime/engine_effect.dart';
import '../state/wallet.dart';
import 'command.dart';

/// Crystal economy commands.
///
/// The engine only ever moves numbers around; buying crystals with real money
/// is the billing layer's job, which credits the wallet through the same API.
List<CommandHandler> premiumCommands() => <CommandHandler>[
      FunctionCommand(const <String>['crystals'], _crystals),
      FunctionCommand(const <String>['require_crystals'], _requireCrystals),
      FunctionCommand(const <String>['open_store'], _openStore),
      FunctionCommand(const <String>['premium_unlock'], _premiumUnlock),
    ];

/// `@crystals +25 reason "daily"` / `@crystals -15`
CommandOutcome _crystals(CommandContext ctx) {
  final int amount = ctx.integer(0, 0);
  if (amount == 0) return CommandOutcome.next;

  ctx.engine.state.updateWallet((Wallet wallet) =>
      amount > 0 ? wallet.earn(amount) : wallet.spend(-amount));

  ctx.engine.emitEvent(
    amount > 0 ? EngineEvents.crystalsGranted : EngineEvents.crystalsSpent,
    data: <String, Object?>{
      'amount': amount.abs(),
      'reason': ctx.namedStr('reason', 'script'),
    },
  );

  if (!ctx.namedBool('silent')) {
    ctx.engine.emitEffect(ToastEffect(
      amount > 0 ? '+$amount crystals' : '$amount crystals',
      icon: 'crystal',
    ));
  }
  return CommandOutcome.next;
}

/// Blocks the story unless the player can afford [amount]; otherwise jumps to
/// `else` (or opens the store).
CommandOutcome _requireCrystals(CommandContext ctx) {
  final int amount = ctx.integer(0, EngineDefaults.defaultPremiumCost);
  if (ctx.engine.state.wallet.canAfford(amount)) return CommandOutcome.next;

  final String? fallback = ctx.namedStrOrNull('else');
  ctx.engine.emitEffect(StoreEffect(
    reason: 'require_crystals',
    requiredCrystals: amount,
  ));
  if (fallback != null) return CommandOutcome.jump(fallback);
  return CommandOutcome.next;
}

CommandOutcome _openStore(CommandContext ctx) {
  ctx.engine.emitEffect(StoreEffect(
    sku: ctx.namedStrOrNull('sku'),
    reason: ctx.namedStr('reason', 'script'),
  ));
  ctx.engine.emitEffect(const NavigateEffect('/store'));
  return CommandOutcome.next;
}

/// One-shot paid unlock (gallery image, bonus scene…).
CommandOutcome _premiumUnlock(CommandContext ctx) {
  final String id = ctx.id(0);
  if (id.isEmpty) return CommandOutcome.next;

  final int cost = ctx.namedInt('cost', EngineDefaults.defaultPremiumCost);
  final Wallet wallet = ctx.engine.state.wallet;

  if (wallet.hasUnlockedChoice(id)) return CommandOutcome.next;

  if (!wallet.canAfford(cost)) {
    ctx.engine.emitEffect(
        StoreEffect(reason: 'premium_unlock', requiredCrystals: cost));
    final String? fallback = ctx.namedStrOrNull('else');
    if (fallback != null) return CommandOutcome.jump(fallback);
    return CommandOutcome.next;
  }

  ctx.engine.state
      .updateWallet((Wallet w) => w.spend(cost, choiceId: id));
  ctx.engine.state.setFlag('premium_$id');
  ctx.engine.emitEvent(EngineEvents.crystalsSpent,
      data: <String, Object?>{'amount': cost, 'unlock': id});
  ctx.engine.emitEffect(ToastEffect(
    ctx.namedStr('title', 'Unlocked'),
    icon: 'crystal',
  ));
  return CommandOutcome.next;
}
