#include "PROTHEUS.CH"
#include "topconn.ch"
#include "tbiconn.ch"

/*__________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦  FA040ALT	¦ Autor ¦ Lucilene Mendes    ¦ Data ¦24.11.22 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦  Ponto de entrada na alteração de titulo a receber         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function FA040ALT()
Local lAPI:= SE1->E1_PORTADO $ GetNewPar("AC_BCOAPI","001")

//Alteração de vencimento
If lAPI .and. AliasinDic("ZLA") .and. M->E1_VENCTO <> SE1->E1_VENCTO
	//Identifica se o título foi enviado para o banco
	If ZLA->(dbSeek(xFilial("ZLA")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
		If !Empty(SE1->E1_IDCNAB) .and. ZLA->ZLA_STATUS = '2' //Entrada confirmada
			If MsgYesNo("Confirma o envio da alteração de vencimento para o Banco do Brasil?")
				FWMsgRun(,{|| u_XAG0115()},"Integração com o Banco do Brasil","Enviando alteração do título... Aguarde...")
			Endif
		Endif
	Endif
Endif

Return .T.
