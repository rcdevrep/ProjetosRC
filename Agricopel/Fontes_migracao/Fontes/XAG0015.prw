#INCLUDE "RWMAKE.CH"

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 22/11/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Conta Credito de Longo Prazo para planilhas de Juros.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function XAG0015()

	Private cCtaCre := ""                                                                                  	

	//CN9->CN9_XCTCUR OU CN9->CN9_XCTLON    

	If FunName() = "CNTA260" .and. CNA->CNA_XJUROS = 'S'	

		cCtaCre :=  CN9->CN9_XCTCUR    

	Endif

Return(cCtaCre)