#Include 'Protheus.ch'


User Function MTA140MNU() 

IF cEmpAnt == '01' .AND. cFilAnt == '06'
	aAdd(aRotina,{ "Lib.Conf.Cega", "U_LibConf()" , 0 , 2, 0, .F.})
ENDIF

Return    

USER Function LibConf()

	IF SF1->F1_STATUS == 'X' 
	
			RECLOCK("SF1",.F.)
			SF1->F1_STATUS := ''
			SF1->(MSUNLOCK())
			
			MSGINFO("Documento Liberado","Lib.Conf.Cega")
	ELSE
		MSGALERT("Este documento não se encontra bloqueado","Lib.Conf.Cega")
	ENDIF

RETURN
