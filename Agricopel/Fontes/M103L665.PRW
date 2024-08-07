#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M103L665 � Autor � Osmar Schimitberger � Data �  16/08/2018 ���
�������������������������������������������������������������������������͹��
���Descricao � Contabilizar Exclusao mudando data base para data de       ���
���          � contabiliza��o da Entrada                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Agricopel                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function M103L665()

Local cLote  := "8810"
Local cArquivo:= ""
Local lOnline:= .F.
Local cPadrao := "655"
Local dDataB := ddatabase
Local cLoteCtb:= PARAMIXB[1] //= Lote para Lan�amento Cont�bil
Local nTotalLcto:= 0
Local aDiario:= {}
Local lLancOk:= .F.
Local aArea := GetArea()
Local nValor 	:= 0
Local nHdlPrv  	:=  0 //paramixb[2]
Local lDigita	:= .T. //paramixb[4]
Local lAglutina	:= .F.//paramixb[5]
Local aCtbInf	:= {} //Array contendo os dados para contabiliza��o on line

lOnline	:= VerPadrao(cPadrao)

//�������������������������������������������������������������Ŀ
//� Manipula a database para efetuar o lancamento em outra data �
//���������������������������������������������������������������
//muda data exclusao na contabiliza��o on-line
If cLoteCtb == cLote //lanctos on-line = SIM
	ddatabase:= SF1->F1_DTDIGIT
Endif


If lOnline .and. cLoteCtb <> cLote .and. !empty(SF1->F1_DTLANC) ////lanctos on-line = NAO (Contabiliza de qualquer jeito na exclusao do Documento de Entrada
	
	//muda data exclusao na contabiliza��o off-line
	ddatabase:= SF1->F1_DTDIGIT
	
	nHdlPrv:= HeadProva(cLote,"MATA103",Subs(cUsuario,7,6),@cArquivo)
	                         
    nValor += DetProva(nHdlPrv,cPadrao,"MATA103",cLote)
                
    If nValor > 0
        RodaProva(nHdlPrv,nValor)
		aAdd(aCtbInf,cArquivo)
		aAdd(aCtbInf,nHdlPrv)
		aAdd(aCtbInf,cLote)
		aAdd(aCtbInf,lDigita)
		aAdd(aCtbInf,lAglutina)
		aAdd(aCtbInf,{{"F1_DTLANC",dDataBase,"SF1",SF1->(Recno()),0,0,0}})
	EndIf 
	
	If Len(aCtbInf) != 0 
	
	   Begin Transaction
	   cA100Incl(aCtbInf[1],aCtbInf[2],3,aCtbInf[3],aCtbInf[4],aCtbInf[5],,,,aCtbInf[6])
	   End Transaction
	Endif
	
	aCtbInf	:= {}
	
	RestArea(aArea)
	ddatabase:= dDataB
	
Endif     

Return