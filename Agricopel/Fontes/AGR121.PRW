#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGR121    ºAutor  ³Deco                º Data ³  16/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Programa para Credito lancamento padrao 650-05            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AGR121()

PRIVATE cCtaCre


If SD1->D1_TIPO <> 'D'
	
	If  Alltrim(SD1->D1_CF) == '1659' .or.; // Transferencias produtos 9926 9927 9912 9915
		Alltrim(SD1->D1_CF) == '1152' .or.;
		Alltrim(SD1->D1_CF) == '1409' .or.;
		Alltrim(SD1->D1_CF) == '2152'       // Tranferencias produtos para Filiais do Posto Mime fora de SC (Filiais PR)
		
		cCtaCre := "112070010" // Alteração Leandro/Alexandre (14/12/2012) - Sempre usarão esta conta crédito para transferência
		
	Else
		cCtaCre := SA2->A2_CONTA
	EndIf
	
	
Else
	cCtaCre := SA1->A1_CONTA
Endif

If SF4->F4_CODIGO == '051' .or.;
	SF4->F4_CODIGO == '169' .or.;
	SF4->F4_CODIGO == '069'
	//Adcionado por Willian conforme Solicitação Alexandre
	cCtaCre := '111010001'
EndIf

If SF4->F4_CODIGO == "070"
	cCtaCre := "112070012"
EndIf

//Empresa 01 - Nova Reggra LP 650-001 chamado 74046 de 27/09/2018
If SM0->M0_CODIGO == "01"

 	cCtaCre:= SA2->A2_CONTA
	
	If SUBS(SD1->D1_CF,2,3)=="659".OR.SUBS(SD1->D1_CF,2,3)=="152"
		
		cCtaCre:= "112070006"
		
	ElseIf  ALLTRIM(SD1->D1_COD) == 'DBP01233' .or. ;  //$'DBP01233/DBP01234/DBP01472/DBP01475/DBP01477/DBP01278'
		    ALLTRIM(SD1->D1_COD) == 'DBP01234' .or.	ALLTRIM(SD1->D1_COD) == 'DBP01472' .or. ;
		    ALLTRIM(SD1->D1_COD) == 'DBP01475' .or.	ALLTRIM(SD1->D1_COD) == 'DBP01477' .or. ;
		    ALLTRIM(SD1->D1_COD) == 'DBP01278' .or. ALLTRIM(SD1->D1_COD) == 'DBP00381' .or. ;
		    ALLTRIM(SD1->D1_COD) == 'DBP03310'
		
		cCtaCre:= "112040072"
		
	

    ElseIf  ALLTRIM(SD1->D1_COD) == 'DBP02985' .or.  ALLTRIM(SD1->D1_COD) == 'DBP02986' .or. ;
	        ALLTRIM(SD1->D1_COD) == 'DBP02987' .or.  ALLTRIM(SD1->D1_COD) == 'DBP02988'

		
		 cCtaCre:= "112040074"   


	 ElseIf  ALLTRIM(SD1->D1_COD) == 'DBS00044' .or. ALLTRIM(SD1->D1_COD) == 'DBS00041'
	
	     cCtaCre:= "115010002"    

	 ElseIf  ALLTRIM(SD1->D1_COD) == 'DBP05085'  .or. ALLTRIM(SD1->D1_COD) == 'DBP05086' .or.  ;
	         ALLTRIM(SD1->D1_COD) == 'DBP05087'  .or. ALLTRIM(SD1->D1_COD) == 'DBP05088'  .or.  ;
			 ALLTRIM(SD1->D1_COD) == 'DBP05089' 
	    
		 cCtaCre:= "112040110" 

	Endif	 
 
	
Endif

/*
* pegar cnpj do fornecedor e comparar com cnpj da filial da nota de entrada
* se o cnpj do fornecedor for igual ao da filial, fazer as seguintes condicoes
*  se D1_CF = '1949' e B1_CONTA = '112070001' or B1_CONTA = '112070003'
*  conta credito: B1_CONTA
*
*  se D1_CF = '1949' e B1_CONTA = '112070002' ou B1_CONTA = '112070004'
*  conta credito: B1_CONTA
*
*  se D1_CF = '1927' e B1_CONTA = '112070002' ou B1_CONTA = '112070004'
*  conta credito: B1_CONTA
*
*  necessario ajustar a rotina para poder aplicar em producao, ai tem que remover a validacao do 1==3
*  Solicitação da Elaine contabilidade, todos os creditos devem cair na conta 112070012
*/

if cEmpAnt == "20"
	PRIVATE cFilCNPJ   := ''
	PRIVATE cA2PJ      := ''
	PRIVATE cContaProd := ''
	Private _aareaSM0  := SM0->(getarea())
	
	DbSelectArea("SM0")
	DbGotop()
	While !Eof()
		If SM0->M0_CODIGO == cEmpAnt
			If  Alltrim(SD1->D1_FILIAL) == Alltrim(SM0->M0_CODFIL)
				cFilCNPJ := Transform(SM0->M0_CGC, "@R 99.999.999/9999-99")
				
				If !Empty(ALLTRIM(SD1->D1_FORNECE))
					cPessoa:= Transform(SA2->A2_CGC, "@R 99.999.999/9999-99")
					cA2PJ := ALLTRIM(cPessoa)
				EndIf
				
				if ((!empty(ALLTRIM(cFilCNPJ)) .and. !empty(ALLTRIM(cA2PJ))) .and. (ALLTRIM(cFilCNPJ) == ALLTRIM(cA2PJ)))
					//if SB1->B1_CONTA <> ""
					cContaProd := "112070012" // alteracao solicitada pela Elaine da contabilidade SB1->B1_CONTA
					//EndIf
					
					If (Alltrim(SD1->D1_CF) == '1949') .or. (Alltrim(SD1->D1_CF) == '1927')
						//If ((Alltrim(cContaProd) == '112070001') .or. (Alltrim(cContaProd) == '112070002').or.;
						//    (Alltrim(cContaProd) == '112070002') .or. (Alltrim(cContaProd) == '112070004'))
						cCtaCre := cContaProd
						//EndIF
					EndIf
				EndIf
			EndIf
		EndIf
		DbSelectArea("SM0")
		DbSkip()
	EndDo
	
	Restarea(_aareaSM0)

EndIf

Return(cCtaCre)
