#Include 'Protheus.ch' 
#Include "topconn.ch"    

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 03/11/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Baixa Automatica Contas a Pagar.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function FA050FIN()
/*
	lMsErroAuto := .F.
	dDataOld    := dDataBase

	nPis        := 0
	nCsll       := 0
	nCofins     := 0
	dBaixa      := IIf(dtos(ddatabase) < dtos(se2->e2_emis1),se2->e2_emis1,ddatabase)
	dDtCredito  := IIf(dtos(ddatabase) < dtos(se2->e2_emis1),se2->e2_emis1,ddatabase)
	cMotBx      := "GCT"
	nTxMoeda    := iif(se2->e2_moeda > 0,iif(se2->e2_txmoeda > 0,se2->e2_txmoeda,RecMoeda(dBaixa,se2->e2_moeda)),0)
	Fa080Data(nTxMoeda,.t.)
	aBaixa  :=  {{"E2_PREFIXO"  ,SE2->E2_PREFIXO ,Nil},;
				{"E2_NUM"      ,SE2->E2_NUM	  		 		 ,Nil},;
				{"E2_PARCELA"  ,SE2->E2_PARCELA				 ,Nil},;
				{"E2_TIPO"	 ,SE2->E2_TIPO	  		   		 ,Nil},;
				{"E2_FORNECE"  ,SE2->E2_FORNECE		   		 ,Nil},;
				{"E2_LOJA"     ,SE2->E2_LOJA		 		 ,Nil},;
				{"AUTMOTBX"	 ,cMotBx					 	 ,Nil},;
				{"AUTBANCO"	 ,""							 ,Nil},;
				{"AUTAGENCIA"  ,""							 ,Nil},;
				{"AUTCONTA"	 ,""							 ,Nil},;
				{"AUTDTBAIXA"  ,dBaixa   					 ,Nil},;
				{"AUTDTCREDITO",dDtCredito					 ,Nil},;
				{"AUTDTHIST"   ,"Baixa Automatica"			 ,Nil},;
				{"AUTDESCONT"  ,0              	  			 ,Nil},;
				{"AUTMULTA"    ,0           		  	  	 ,Nil},;
				{"AUTJUROS"    ,0           		  	  	 ,Nil},;
				{"AUTOUTGAS"   ,0 							 ,Nil},;
				{"AUTVLRPG"    ,SE2->E2_VALOR				 ,Nil},;
				{"AUTVLRME"    ,0 	   						 ,Nil},;
				{"AUTVALREC"   ,SE2->E2_VALOR		 		 ,Nil},;
				{"AUTCHEQUE"   ,""					 		 ,Nil}}	

	MSExecAuto({|x,y| Fina080(x,y)},aBaixa,3)

	if lMsErroAuto
		DisarmTransaction()
		MostraErro()
	endif
*/
Return()