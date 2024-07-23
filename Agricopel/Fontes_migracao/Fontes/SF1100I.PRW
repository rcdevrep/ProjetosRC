#include "rwmake.ch"
#Include "Colors.ch"
#Include "Say.ch"

User Function SF1100I()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SF1100I   ºAutor  ³Microsiga           º Data ³  09/24/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ TELA DE COMPLEMENTO PARA NF DE ENTRADA                     º±±
±±º          ³                                                            º±±
±±º NECESSIDADES : EXIST. DA TABELA SF1 CAMPOS: sf1->f1_transp    C 6     º±±
±±º 											sf1->f1_tpfrete   C 1     º±±
±±º 											sf1->f1_text1     C 3     º±±
±±º 											sf1->f1_volume1   N 5     º±±
±±º 											sf1->f1_especi1   C 20    º±±
±±º 											sf1->f1_pesol     N 7,2   º±±
±±º 											sf1->f1_pesob     N 7,2   º±±
±±º 											sf1->f1_mensnf1   C 60    º±±
±±º 											sf1->f1_mensnf2   C 60    º±±
±±º 											sf1->f1_Placa     C 10    º±±
±±º 											sf1->f1_marca     C 10    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

SetPrvt("NVALFAT,NINSS,CNATINSS,CNATIRRF,NVALMERC,NFRETE")
SetPrvt("NDESPESA,NDESCONT,NIRRF,NVALINSS,NOP2,ACRA")
SetPrvt("NOPC,CTRANSP,CTPFRETE,CTEXT1,CTEXT2,NVOLUME1")
SetPrvt("CESPECI1,NPESOL,NPBRUTO,CMENSA1,CMENSA2,CMENSA3,CPLACA")
SetPrvt("CARQFX,CCAMPOF3,CTEXTO1,CTEXTO3,CTEXTO5,NOP1")
SetPrvt("CDES1,CDES2,CDES3,CDES4,oText1a,oText1b,oText2a,oText2b")

IF SF1->F1_FORMUL == "S"
	
	oTxt1      :=nil
	oTxt2      :=nil
	oDescTransp:=nil
	oDescTransp:=space(60)
	oDesc1     :=Nil
	oDesc1     :=Space(60)
	oDesc2     :=nil
	oDesc2     :=Space(60)
	oDesc3     :=Nil
	oDesc3     :=Space(60)
	oDesc4     :=nil
	oDesc4     :=Space(60)

	cTRANSP  := SPACE(6)
	cTPFRETE := SPACE(1)
	cTEXT1   := SPACE(3)
	cTEXT2   := SPACE(3)
	nVOLUME1 := 0
	cESPECI1 := SPACE(20)
	nPESOL   := 0
	nPBRUTO  := 0
	cMENSA1  := SPACE(60)
	cMENSA2  := SPACE(60)
	cMENSA3  := SPACE(60)
	cPLACA   := SPACE(08)
	cMARCA   := SPACE(10)
	cArqFX   := 'Z5 '
	cCampoF3 := 'F1_TEXTO1'
	cDes1    := SPACE(60)
	cDes2    := SPACE(60)
	cDes3    := SPACE(60)
	cDes4    := SPACE(60)
	cDescTransp:= SPACE(40)  
	
	@ 05,05 TO 400,610 DIALOG oDlg1 TITLE "Complemento p/ Nota Fiscal Entrada"
	@ 05,05 TO 180,300
	@ 010,010 Say oLblTransp var "Transportadora : " pixel
	@ 010,050 Get cTransp F3 'SA4' valid existcpo('SA4') .and. MudaTransp() object oTransp
	@ 010,100 SAY oDescTransp VAR cDescTransp pixel size 150,10 COLOR CLR_HRED
	@ 020,010 Say oLblFrete var "Tipo Frete :     "+space(10)+" (C)if  ou  (F)ob "  pixel size 150,10
	@ 020,050 Get cTpFrete PICT "@!" valid Pertence("CF")

	@ 030,010 Say oLblTxt1 var "Texto Legal 1 :    " pixel
	@ 030,050 GET cText1 PICT "@!" F3 "SZ4" valid MudaTxt1() object oTxt1
	@ 030,100 SAY oDesc1 var  cDes1  pixel size 200,10 COLOR CLR_HRED 
	@ 040,100 SAY oDesc2 var  cDes2  pixel size 200,10 COLOR CLR_HRED 

 	@ 050,010 Say oLbltxt2 var "Texto Legal 2 :    "  pixel
	@ 050,050 Get cText2 PICT "@!" F3 "SZ4" valid MudaTxt2() object oTxt2
	@ 050,100 SAY oDesc3 var cDes3  pixel size 200,10 COLOR CLR_HRED
	@ 060,100 SAY oDesc4 var cDes4  pixel size 200,10 COLOR CLR_HRED

	@ 080,010 Say oLblvolume var "Volume :         "  pixel
	@ 080,050 Get nVolume1 pict "99999"
	@ 090,010 Say oLblespecie var "Especie :        " pixel
	@ 090,050 Get cEspeci1 Pict "@!" //F3 "SZ6"
	@ 100,010 Say oLblPesol var "Peso Liquido :   "   pixel
	@ 100,050 Get nPesol pict  "@E 99,999.99"
	@ 110,010 Say oLblPesob var "Peso Bruto :     "   pixel
	@ 110,050 Get nPBruto pict "@E 99,999.99"
	@ 120,010 Say oLblMens var "Mensagem :       "    pixel
	@ 120,050 Get cMensa1 PICT "@!" SIZE 200,80
	@ 130,050 Get cMensa2 PICT "@!" SIZE 200,80
	@ 140,050 Get cMensa3 PICT "@!" SIZE 200,80
	@ 150,010 Say oLblPlaca var "Placa :          "   pixel
	@ 150,050 Get cPlaca  PICT "@!S08"
	@ 185,260 BUTTON "Confirma" Size 40,10  ACTION GRAVA_F1()
    MudaTransp()
    MudaTxt1()
    MudaTxt2() 
    oDlg1:Refresh()
	ACTIVATE DIALOG oDlg1 CENTERED
ENDIF  
return .t.

Static FUNCTION GRAVA_F1()
*****************
Close(oDlg1)

Reclock("SF1",.F.)
SF1->F1_TRANSP  := cTRANSP
SF1->F1_TPFRETE := cTPFRETE
SF1->F1_TEXT1   := cTEXT1
SF1->F1_TEXT2   := cTEXT2
SF1->F1_VOLUME1 := nVOLUME1
SF1->F1_ESPECI1 := cESPECI1
SF1->F1_PESOL   := nPESOL
SF1->F1_PESOB   := nPBRUTO
SF1->F1_MENSNF1 := SUBSTR(cMENSA1,1,60)
SF1->F1_MENSNF2 := SUBSTR(cMENSA2,1,60)
SF1->F1_MENSNF3 := SUBSTR(cMENSA3,1,60)
SF1->F1_PLACA   := cPLACA
MsUnLock("SF1")
Return .T.

Static Function MudaTransp()
DbSelectArea("SA4")
DbSetOrder(1)
DbSeek(xFilial("SA4")+cTransp)
cDescTransp:=SA4->A4_NOME
oDescTransp:Refresh() 
oDlg1:Refresh()
Return .t.

Static Function MudaTxt1()
DbSelectARea("SZ4")
DbSetOrder(1)
DbSeek(xFilial("SZ4")+cText1)
cDes1:=SZ4->Z4_DESC1
cDes2:=SZ4->Z4_DESC2
oDesc1:Refresh()
oDesc2:Refresh()
return .t.

Static Function MudaTxt2()
DbSelectARea("SZ4")
DbSetOrder(1)
DbSeek(xFilial("SZ4")+cText2)
cDes3:=SZ4->Z4_DESC1 
cDes4:=SZ4->Z4_DESC2
oDesc3:Refresh()
oDesc4:Refresh()
Return .t.
