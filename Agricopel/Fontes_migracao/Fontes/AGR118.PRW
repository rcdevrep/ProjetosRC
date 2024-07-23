#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} AGR118
//Programa para Debito lancamento padrao 610-01
@author Deco
@since 05/07/2004
@version 1
@type function
/*/
User Function AGR118()

	Local cCtaDeb := '112010004'

	If Substr(SF4->F4_CF,2,3) == '151' .or.;  // Transferencias produtos 9926 9927 9912 9915
	   Substr(SF4->F4_CF,2,3) == '152' .or.;
	   Substr(SF4->F4_CF,2,3) == '409' .or.;
	   Substr(SF4->F4_CF,1,4) == '5659'

		cCtaDeb := "112070010"  // Alteração Leandro/Alexandre (14/12/2012) - Sempre usarão esta conta crédito para transferência
	EndIf

	If Substr(SF4->F4_CF,1,4) == '5201' .or.;
	   Substr(SF4->F4_CF,1,4) == '5202' .or.;
	   Substr(SF4->F4_CF,1,4) == '5411'
		cCtaDeb := SA2->A2_CONTA
	EndIf

	If SF4->F4_CODIGO == "518" .OR. ;
	   SF4->F4_CODIGO == "519" 
		cCtaDeb := "52111531"
	EndIf

	If Alltrim(SF4->F4_CF) $ "5910/6910" // Chamado 137724 - Verificar integração de saídas entre Protheus e AutoSystem na empresa 20
		cCtaDeb := "52111923"
	EndIf

	If SF4->F4_CODIGO == "535" .OR.;
       SF4->F4_CODIGO == "536"
		cCtaDeb := "112070012"
	EndIf                    
	
Return(cCtaDeb)