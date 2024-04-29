#Include 'Protheus.ch'

// RC CONSULTORIA
// EVANDRO BURLIN
// PE MA103BUT - ADD BOTAO "Enviar P/ Recebimento
// PROJETO - MELHORIA PROCESSO DE RECEBIMENTO
// DATA - 24/04/2024
USER FUNCTION MA103BUT()
	Local aButtons := {}

	aadd(aButtons, {'Enviar P/ Recebimento', {||U_RCTEC04(l103Class)}, 'Enviar P/ Recebimento'})


Return (aButtons)
