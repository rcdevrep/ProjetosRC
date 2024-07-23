#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AGR248A   �Autor  �Microsiga           � Data �  08/14/03   ���
�������������������������������������������������������������������������͹��
���Desc.     � Pesquisa Condicoes de Pagamento para Regra de Desconto.    ���
���          �                                                            ���
���          � Atencao: Quando for liberado para Agricopel, devera ser    ���
���          � aglutinada esta logica com a logica do agr248.prw          ���
���          �                                                            ���
���          � Criar Indice:                                              ���
���          � (3) ACO  ACO_FILIAL+ACO_CODCLI+ACO_LOJA+ACO_CODTAB         ���
���          �                                                            ���
���          � Alterar no dicionario de dados, o F3 para o campo          ���
���          � SUA_CONDPG, para F3 igual MA8                              ���
���          �                                                            ���
���          � Criar SXB, com XB_ALIAS = MA8                              ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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

