#INCLUDE "RWMAKE.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA080TIT�Autor  �Rafael Ramos Lavinas� Data �  04/18/19     ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada para permitir ou n�o usuario altera       ���
���          � valores de impostos.                                       ���
�������������������������������������������������������������������������͹��
���Uso       � STATEGRID                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function FA080TIT
Local lRet	:= .T.
Local aArea := GetArea()
Local aBaixa           := {}
Private lMsErroAuto    := .F.

	//������������������������������������������������������������������������Ŀ
	//�Criado ponto de lan�amento especifico quando ocorrer baixa do lan�amento�
	//�e n�o ter que estornar quando cancelar.                                 �
	//��������������������������������������������������������������������������
	PcoVldLan("900006","01","FINA080",/*lUsaLote*/,/*lDeleta*/, /*lVldLinGrade*/)


    //Em caso de T�tulo de Devolu��o, � realizada uma baixa manual por DAC no Contas a Receber - Jader Berto
    If !Empty(SE2->E2_XRECSE1)

        DbSelectArea("SE1")
        SE1->(DbSetOrder(1))
		SE1->(DbGoTo(val(SE2->E2_XRECSE1)))
        If !Empty(SE1->E1_NUM)
            
            aAdd( aBaixa, {"E1_FILIAL"   , SE1->E1_FILIAL    , Nil } )
            aAdd( aBaixa, {"E1_PREFIXO"  , SE1->E1_PREFIXO   , Nil } )
            aAdd( aBaixa, {"E1_NUM"      , SE1->E1_NUM       , Nil } )
            aAdd( aBaixa, {"E1_PARCELA"  , SE1->E1_PARCELA   , Nil } )
            aAdd( aBaixa, {"E1_TIPO"     , SE1->E1_TIPO      , Nil } )
            aAdd( aBaixa, {"E1_CLIENTE"  , SE1->E1_CLIENTE   , Nil } )
            aAdd( aBaixa, {"E1_LOJA"     , SE1->E1_LOJA      , Nil } )  
            aAdd( aBaixa, {"AUTMOTBX"    , "DAC"             , Nil } )
            aAdd( aBaixa, {"AUTDTBAIXA"  , dDataBase         , Nil } ) 
            aAdd( aBaixa, {"AUTDTCREDITO", dDataBase         , Nil } )
            aAdd( aBaixa, {"AUTHIST"     , 'BAIXA '          , Nil } )
            aAdd( aBaixa, {"AUTVLRPG"    , SE1->E1_SALDO     , Nil } )

            MsExecAuto( {|ER,UD| FINA070(ER,UD)}, aBaixa, 3 )

        Else
            IF !ISBLIND()
                Help("Help", "Na tentativa de realizar a baixa da devolu��o, o t�tulo n�o foi encontrado.", "Certifique-se que o t�tulo de baixa a pagar n�o tenha sido exclu�do.")
            Else
                console.log("Na tentativa de realizar a baixa da devolu��o, o t�tulo n�o foi encontrado. Certifique-se que o t�tulo de baixa a pagar n�o tenha sido exclu�do.")
            EndIf
        EndIf

    EndIf

	RestArea(aArea)

Return (lRet)
