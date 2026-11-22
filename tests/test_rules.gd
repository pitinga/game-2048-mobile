extends SceneTree

const Rules := preload("res://scripts/rules.gd")
var failures := 0


func check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)


func _initialize() -> void:
	var game = Rules.new()
	game.reset()
	check(game.board.size() == 16, "tabuleiro 4x4")
	check(game.board.count(2) + game.board.count(4) == 2, "duas peças iniciais")
	game.board.fill(0)
	for i in range(4):
		game.board[i] = 2
	check(game.move("left"), "movimento com fusão")
	check(game.board[0] == 4 and game.board[1] == 4, "cada peça funde apenas uma vez")
	check(game.score == 8, "pontuação da fusão")
	check(game.board.count(2) + game.board.count(4) == 3, "nova peça após movimento válido")
	check(not game.move("invalid"), "movimento inválido rejeitado")
	game.reset()
	game.board.fill(0)
	game.board[0] = 1024
	game.board[1] = 1024
	game.move("left")
	check(game.won and game.awaiting_continue and not game.ended, "meta 2048 reconhecida sem encerrar partida")
	check(not game.move("right"), "aguarda escolha explícita após vencer")
	game.continue_after_win()
	check(not game.awaiting_continue and not game.ended, "CONTINUAR mantém partida ativa")
	check(game.move("right"), "jogada adicional aceita após 2048")
	game.board.assign([2, 4, 2, 4, 4, 2, 4, 2, 2, 4, 2, 4, 4, 2, 4, 2])
	check(not game.can_move(), "tabuleiro bloqueado")
	game.move("up")
	check(game.ended, "detecta fim mesmo após tentativa sem deslocamento")
	finish()


func finish() -> void:
	print("2048: %s" % ("OK" if failures == 0 else "%d falhas" % failures))
	quit(0 if failures == 0 else 1)
