#include "Protheus.ch"
#include "Tbiconn.ch"
#include "Topconn.ch"
#INCLUDE "colors.ch"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAGX485    บAutor  ณMicrosiga           บ Data ณ  09/15/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/



User Function AGX485

	Local cPerg :=  "" 
	Local aRegistros := {}

	cPerg := "AGX485"
	aRegistros := {}

	AADD(aRegistros,{cPerg,"01","Prefixo               ?","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})	
	AADD(aRegistros,{cPerg,"02","Numero                ?","mv_ch2","C",TamSX3("E1_NUM")[1],0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})		
	AADD(aRegistros,{cPerg,"03","Parcela               ?","mv_ch3","C",01,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})		
	AADD(aRegistros,{cPerg,"04","Cliente               ?","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SA1"})  
	AADD(aRegistros,{cPerg,"05","Loja                  ?","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})  
	AADD(aRegistros,{cPerg,"06","Vencimento            ?","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})  	
	AADD(aRegistros,{cPerg,"07","Valor                 ?","mv_ch7","N",16,2,0,"G","","mv_par07","","","","","","","","","","","","","","",""}) 

	U_CriaPer(cPerg,aRegistros)
	
	If !Pergunte(cPerg,.T.)
		Return
	EndIf                                                                                         
  
   	Processa({|| GeraTit()}, "Gravando...")	  

Return()

Static Function GeraTit()

	Local lOk := .f.    
	Local cStartPath	:= GetSrvProfString("Startpath","")
	Local _aTitulo := {}

	dbSelectArea("SE1")
	dbSetOrder(1)
	dbgotop()
	If !dbseek(xFilial("SE1")+mv_par01+PADL(alltrim(mv_par02),6,"0")+mv_par03+"NCF")

		lOk := .f.
	    Aadd(_aTitulo,{"E1_FILIAL" ,xFilial("SE2")     ,Nil})
		Aadd(_aTitulo,{"E1_PREFIXO",mv_par01                ,Nil})
		Aadd(_aTitulo,{"E1_NUM"    ,PADL(ALLTRIM(mv_par02),6,"0")           ,Nil})
		Aadd(_aTitulo,{"E1_PARCELA",mv_par03,Nil})
		Aadd(_aTitulo,{"E1_CLIENTE",mv_par04     ,Nil})
		Aadd(_aTitulo,{"E1_TIPO"   ,"NCF"               ,Nil})
		Aadd(_aTitulo,{"E1_LOJA"   ,mv_par05          ,Nil})
		Aadd(_aTitulo,{"E1_NATUREZ","219130"     ,Nil})
		Aadd(_aTitulo,{"E1_EMISSAO",dDatabase     ,Nil})
		Aadd(_aTitulo,{"E1_VENCTO" ,mv_par06     ,Nil})
		Aadd(_aTitulo,{"E1_VENCREA",DataValida(mv_par06),Nil})
		Aadd(_aTitulo,{"E1_VALOR" ,mv_par07     ,Nil})
		Aadd(_aTitulo,{"E1_EMIS1" ,dDataBase          ,Nil})   
		Aadd(_aTitulo,{"E1_HIST" ,"LANC.MANUAL REF BONIFICACAO"          ,Nil})          
    	Aadd(_aTitulo,{"E1_MOEDA" ,1          ,Nil})          

	                    lMsErroAuto := .T.
	                    MSExecAuto({|x,y| Fina040(x,y)}, _aTitulo, 3)

						If lMsErroAuto
							MostraErro(cStartPath,"AGX485.log")
						Endif

	                    msgInfo("Opera็ใo Realizada Com Sucesso!")
   Else 
      Alert("Aten็ใo! Tํtulo jแ cadastrado no contas a Receber! Verifique ")   
   EndIf

Return()