#INCLUDE "RWMAKE.CH"

/*/
=============================================================
Programa     : 
Autor        : Cesar Tenfen Heidemann
Data         : 22/11/2017
Alterado por : 
Data         : 
-------------------------------------------------------------
Descricao    : Conta Debito de Longo Prazo para planilhas de Juros.
Módulo (Uso) : SIGAGCT
=============================================================
/*/

User Function XAG0014()

	Private cCtaDeb := " "                                                                                  	

	//CN9->CN9_XCTCUR OU CN9->CN9_XCTLON      

	If FunName() = "CNTA260" .and. CNA->CNA_XJUROS = 'S'	

		cCtaDeb :=  CN9->CN9_XCTLON      

	Endif

Return(cCtaDeb)