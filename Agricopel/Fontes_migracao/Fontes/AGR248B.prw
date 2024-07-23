#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR248A   ºAutor  ³Microsiga           º Data ³  08/14/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa Condicoes de Pagamento para Regra de Desconto.    º±±
±±º          ³                                                            º±±
±±º          ³ Atencao: Quando for liberado para Agricopel, devera ser    º±±
±±º          ³ aglutinada esta logica com a logica do agr248.prw          º±±
±±º          ³                                                            º±±
±±º          ³ Criar Indice:                                              º±±
±±º          ³ (3) ACO  ACO_FILIAL+ACO_CODCLI+ACO_LOJA+ACO_CODTAB         º±±
±±º          ³                                                            º±±
±±º          ³ Alterar no dicionario de dados, o F3 para o campo          º±±
±±º          ³ SUA_CONDPG, para F3 igual MA8                              º±±
±±º          ³                                                            º±±
±±º          ³ Criar SXB, com XB_ALIAS = MA8                              º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR248B()
	Setprvt("cteste") 
	
	If SM0->M0_CODIGO <> "02"
		If cModulo == "TMK"
//			if SM0->M0_CODIGO == '01' .And. SM0->M0_CODFIL == "03"
   		if SM0->M0_CODIGO == '01' .And. SM0->M0_CODFIL >= "02" // Feito Deco p/Pien vender combustivel
				cTeste := "ACO"
			else
				cTeste := "SE4"
			endif
		ElseiF cModulo <> "TMK"
				cTeste := "SE4"
		EndIf
	Else
		If SM0->M0_CODIGO == '02' .And.  FunName() == "TMKA271"
			cTeste := "ACO"
		else
			cTeste := "SE4"
		endif
	EndIf
			
Return cteste

User Function AGR248C()
	Setprvt("cteste") 
	
	If SM0->M0_CODIGO <> "02"
		If cModulo == "TMK"
//			if SM0->M0_CODIGO == '01' .And. SM0->M0_CODFIL == "03"
			if SM0->M0_CODIGO == '01' .And. SM0->M0_CODFIL >= "02" // Feito p/Pien vender combustivel
				cTeste := "ACO->ACO_CONDPG"
			else
				cTeste := "SE4->E4_CODIGO"
			endif
		ElseiF cModulo <> "TMK"
				cTeste := "SE4->E4_CODIGO"
		EndIf
	Else
		If SM0->M0_CODIGO == '02' .And.  FunName() == "TMKA271"
			cTeste := "ACO->ACO_CONDPG"
		else
			cTeste := "SE4->E4_CODIGO"
		endif
	EndIf
			
Return cteste

