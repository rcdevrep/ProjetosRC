#INCLUDE "RWMAKE.CH"
#include "protheus.ch"

/*/{Protheus.doc} AGR209
Gatilho para Alimentar campos contas no cadastro do produto - Campo B1_TIPO
@author Deco
@since 22/05/06
@return Nil, Função não tem retorno
/*/

User Function AGR209()

	Local cTipo := M->B1_TIPO
	Local cRetu := &(ReadVar())
	Local aSeg  := GetArea()

	Local oMdlSb1     := Nil
	Local oSb1Master  := Nil

	oMdlSb1    := fwModelActive()
	oSb1Master := oMdlSb1:getModel("SB1MASTER")

	oSb1Master:LoadValue("B1_CONTA", SPACE(15))
	oSb1Master:LoadValue("B1_CTAREC", SPACE(15))
	oSb1Master:LoadValue("B1_CTADEV", SPACE(15))
	oSb1Master:LoadValue("B1_CTAICMS", SPACE(15))

	If Alltrim(cTipo) == 'LU'
		oSb1Master:LoadValue("B1_CONTA"  , '112070012')
		oSb1Master:LoadValue("B1_CTAREC" , '51110112')
		oSb1Master:LoadValue("B1_CTADEV" , '51120112')
		oSb1Master:LoadValue("B1_CTAICMS", '51120312')
		oSb1Master:LoadValue("B1_CTAPIS" , '51120512')
		oSb1Master:LoadValue("B1_CTACOFI", '51120612')
	EndIf

	If Alltrim(cTipo) == 'UR'
		oSb1Master:LoadValue("B1_CONTA"  , '112070017')
		oSb1Master:LoadValue("B1_CTAREC" , '51110148')
		oSb1Master:LoadValue("B1_CTADEV" , '51120116')
		oSb1Master:LoadValue("B1_CTAICMS", '51120317')
		oSb1Master:LoadValue("B1_CTAPIS" , '51120546')
		oSb1Master:LoadValue("B1_CTACOFI", '51120646')
	EndIf

	If Alltrim(cTipo) == 'CO'
		oSb1Master:LoadValue("B1_CONTA"  , '112070001')
		oSb1Master:LoadValue("B1_CTAREC" , '51110101')
		oSb1Master:LoadValue("B1_CTADEV" , '51120101')
		oSb1Master:LoadValue("B1_CTAICMS", '51120301')
		oSb1Master:LoadValue("B1_CTAPIS" , '51120501')
		oSb1Master:LoadValue("B1_CTACOFI", '51120601')
	EndIf

	If Alltrim(cTipo) == 'PA'
		oSb1Master:LoadValue("B1_CONTA"  , '112070003')
		oSb1Master:LoadValue("B1_CTAREC" , '51110107')
		oSb1Master:LoadValue("B1_CTADEV" , '51120107')
		oSb1Master:LoadValue("B1_CTAICMS", '51120307')
		oSb1Master:LoadValue("B1_CTAPIS" , '51120507')
		oSb1Master:LoadValue("B1_CTACOFI", '51120607')
	EndIf

	If Alltrim(cTipo) == 'VE'
		oSb1Master:LoadValue("B1_CONTA"  , '112070007')
		oSb1Master:LoadValue("B1_CTAREC" , '51110119')
		oSb1Master:LoadValue("B1_CTADEV" , '51120119')
		oSb1Master:LoadValue("B1_CTAICMS", '51120315')
		oSb1Master:LoadValue("B1_CTAPIS" , '51120519')
		oSb1Master:LoadValue("B1_CTACOFI", '51120619')
	EndIf

	If Alltrim(cTipo) == 'LO'
		oSb1Master:LoadValue("B1_CONTA"  , '112070008')
		oSb1Master:LoadValue("B1_CTAREC" , '51110108')
		oSb1Master:LoadValue("B1_CTADEV" , '51120108')
		oSb1Master:LoadValue("B1_CTAICMS", '51120308')
		oSb1Master:LoadValue("B1_CTAPIS" , '51120508')
		oSb1Master:LoadValue("B1_CTACOFI", '51120608')

		If SM0->M0_CODIGO = '01' .And. Alltrim(SM0->M0_CODFIL) = '06'
			oSb1Master:LoadValue("B1_LOCPAD", '02')
		EndIf
	EndIf

	If Alltrim(cTipo) == 'ME'
		oSb1Master:LoadValue("B1_CONTA"  , '112070008')
		oSb1Master:LoadValue("B1_CTAREC" , '51110108')
		oSb1Master:LoadValue("B1_CTADEV" , '51120108')
		oSb1Master:LoadValue("B1_CTAICMS", '51120308')
		oSb1Master:LoadValue("B1_CTAPIS" , '51120608')
		oSb1Master:LoadValue("B1_CTACOFI", '51120508')
	EndIf

	If Alltrim(cTipo) == 'MM'
		oSb1Master:LoadValue("B1_CONTA"  , '112070009')
		oSb1Master:LoadValue("B1_CTAREC" , '51110121')
		oSb1Master:LoadValue("B1_CTADEV" , '51120118')
		oSb1Master:LoadValue("B1_CTAICMS", '51120316')
		oSb1Master:LoadValue("B1_CTAPIS" , '51120522')
		oSb1Master:LoadValue("B1_CTACOFI", '51120622')
	EndIf
       
	If Alltrim(cTipo) == 'AG'
		oSb1Master:LoadValue("B1_CONTA"  , '112070010')
		oSb1Master:LoadValue("B1_CTAREC" , '51110106')
		oSb1Master:LoadValue("B1_CTADEV" , '51120106')
		oSb1Master:LoadValue("B1_CTAICMS", '51120306')
		oSb1Master:LoadValue("B1_CTAPIS" , '51120506')
		oSb1Master:LoadValue("B1_CTACOFI", '51120606')
	EndIf

	If Alltrim(cTipo) == 'SH'
		oSb1Master:LoadValue("B1_CONTA"   , '112070002')
		oSb1Master:LoadValue("B1_CTAREC"  , '51110105')
		oSb1Master:LoadValue("B1_CTADEV"  , '51120105')
		oSb1Master:LoadValue("B1_CTAICMS" , '51120305')
		oSb1Master:LoadValue("B1_CTAPIS"  , '51120505')
		oSb1Master:LoadValue("B1_CTACOFI" , '51120605')
	Endif

	If Alltrim(cTipo) == 'QR'
		oSb1Master:LoadValue("B1_CONTA"  , '112070013')
		oSb1Master:LoadValue("B1_CTAREC" , '51110110')
		oSb1Master:LoadValue("B1_CTADEV" , '51120110')
		oSb1Master:LoadValue("B1_CTAICMS", '51120310')
		oSb1Master:LoadValue("B1_CTAPIS" , '51120510')
		oSb1Master:LoadValue("B1_CTACOFI", '51120610')
	EndIf

	If Alltrim(cTipo) == 'MK'
		oSb1Master:LoadValue("B1_CONTA"  , '112070014')
		oSb1Master:LoadValue("B1_CTAREC" , '51110140')
		oSb1Master:LoadValue("B1_CTADEV" , '51120120')
		oSb1Master:LoadValue("B1_CTAICMS", '51120340')
		oSb1Master:LoadValue("B1_CTAPIS" , '51120540')
		oSb1Master:LoadValue("B1_CTACOFI", '51120640')
	EndIf

	RestArea(aSeg)

Return cRetu
