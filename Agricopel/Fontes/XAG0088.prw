//Bibliotecas
#Include "Protheus.ch"
#include "topconn.ch"

/*--------------------------------------------------------------------------------------------------------------*
 | Fonte.:  XAG0088                                                                                             |
 | Desc:  Cópia dos produtos entre filiais                                                                      |
 | Autor: GroundWork                                                                                            |
 *--------------------------------------------------------------------------------------------------------------*/
 
User Function XAG0088


    Local aPergs := {}
    Local aRetParm := {}
    Local cFilOri   := ""
    Local cFilDest  := ""


    Private  cTipoProd  := ""//aRetParm[3]
    Private  cSoAtivos  := ""//aRetParm[4]
    Private  cTipoMovim := ""//aRetParm[5]
    Private  cMovDe     := ""//aRetParm[6]
    Private  cMovAte    := ""//aRetParm[7]


   	aAdd(aPergs, {1,"Filial de Origem",Space(6),  "", "", "SM0", ".T.", 80, .F.}) // MV_PAR01
   	aAdd(aPergs, {1,"Filial de Destino",Space(6),  "", "", "SM0", ".T.", 80, .F.}) // MV_PAR02
    aAdd(aPergs, {1,"Tipo de produto (separar com  / )",Space(30),  "", "", "", ".T.", 80, .F.}) // MV_PAR03
    aAdd(aPergs, {2, "Somente Ativos?",      cSoAtivos, {"S=Sim", "N=Não"},    80, ".T.", .F.})// MV_PAR04
    aAdd(aPergs, {2, "Tipo de Movimentação?",      cTipoMovim, {"N=Não consultar","E=Entrada", "S=Saida"},    80, ".T.", .F.})// MV_PAR05
    aAdd(aPergs, {1, "Movimentação De",  date(),  "", ".T.", "", ".T.", 80,  .F.})// MV_PAR06
    aAdd(aPergs, {1, "Movimentação Até", date(),  "", ".T.", "", ".T.", 80,  .F.})// MV_PAR07


	If ParamBox(aPergs,"Parâmetros",@aRetParm,{||.T.},,,,,,"",.T.,.T.)
		lOk	:= .T.
        cFilOri    := aRetParm[1]
        cFilDest   := aRetParm[2]
        cTipoProd  := aRetParm[3]
        cSoAtivos  := aRetParm[4]
        cTipoMovim := aRetParm[5]
        cMovDe     := aRetParm[6]
        cMovAte    := aRetParm[7]

        Processa( {|| BuscaProd(cFilOri,cFilDest)}, "Processando", "Copiando Produtos...", .f.)
        
    Else
        FWAlertError("Cancelado pelo Usuário", "AGRICOPEL")    
	EndIf

Return

Static Function BuscaProd(cFilOri,cFilDest)
Local cQuery := ""
Local cAli := GetNextAlias()
Local aTipoProd := {}
Local _i := 0 
Private aTitle     := {}
Private aLog     := {}

	aAdd(aTitle, "Os seguintes produtos foram copiados da filial "+Alltrim(cFilOri)+" para a filial "+cFilDest+" ")
	aAdd(aLog,{} )
	aAdd(aLog[Len(aLog)], Padr("Produto",15) + Padr("Filial Destino",06))


    //Formata Tipos 
    aTipoProd := separa(cTipoProd,'/')
    cTipoProd := ""

    For _i := 1 to len(aTipoProd)
        cTipoProd +=  "'"+alltrim(aTipoProd[_i])+"'"+iif(_i <> len(aTipoProd), ",","")
    Next _i
    

    cQuery += " SELECT * FROM "+RetSqlName("SB1")+"  (NOLOCK) WHERE D_E_L_E_T_ = '' AND B1_FILIAL = '"+Alltrim(cFilOri)+"'  AND B1_COD NOT LIKE 'DB%' "
    
    
    If alltrim(cTipoProd) <> '' //Filtra Tipos de Produtos 
        cQuery += " AND B1_TIPO IN ("+cTipoProd+" )"
    Endif 
    If cSoAtivos == 'S'//Filtra ativos
        cQuery += " AND B1_MSBLQL  <> '1' "
    Endif 
    If cTipoMovim == 'E'//Filtra Entradas
        cQuery += " AND  B1_COD IN ( SELECT D1_COD FROM "+RetSqlName("SD1")+" (NOLOCK)   
        cQuery += " WHERE D1_FILIAL = '"+Alltrim(cFilOri)+"' AND D1_DTDIGIT BETWEEN '"+dtos(cMovDe)+"' AND '"+dtos(cMovAte)+"' AND D_E_L_E_T_ = '' )  "
    ElseIf cTipoMovim == 'S'//Filtra Saídas
        cQuery += " AND  B1_COD IN ( SELECT D2_COD FROM "+RetSqlName("SD2")+" (NOLOCK)   
        cQuery += " WHERE D2_FILIAL = '"+Alltrim(cFilOri)+"'  AND D2_EMISSAO BETWEEN '"+dtos(cMovDe)+"' AND '"+dtos(cMovAte)+"' AND D_E_L_E_T_ = '' ) "
    Endif 

    cQuery += " AND B1_COD NOT IN ( "
    cQuery += " SELECT B1_COD FROM "+RetSqlName("SB1")+"  (NOLOCK) WHERE D_E_L_E_T_ = '' AND B1_FILIAL = '"+Alltrim(cFilDest)+"') ORDER BY R_E_C_N_O_ "

    dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery),cAli, .F., .T.)  

    TCSETFIELD(cAli,"B1_VOLUME"   ,"N",6,1) 

    nTotReg := Contar(cAli,"!Eof()")
    (cAli)->(DbGoTop()) 

    ProcRegua(nTotReg) 

        If !(cAli)->(Eof())
            While !(cAli)->(Eof())
                DbSelectArea("SB1")
                DbSetOrder(1)
                If !DbSeek(cFilOri+(cAli)->B1_COD)
                    RecLock("SB1", .T.)          
        
                        SB1->B1_FILIAL		:= Alltrim(cFilDest) 
                        SB1->B1_GRUCOD		:= (cAli)->B1_GRUCOD
                        SB1->B1_PROC		:= (cAli)->B1_PROC	
                        SB1->B1_COD			:= (cAli)->B1_COD		
                        SB1->B1_CODITE		:= (cAli)->B1_CODITE
                        SB1->B1_DESC		:= (cAli)->B1_DESC	
                        SB1->B1_APLICAC		:= (cAli)->B1_APLICAC
                        SB1->B1_TIPO		:= (cAli)->B1_TIPO	
                        SB1->B1_UM			:= (cAli)->B1_UM		
                        SB1->B1_LOCPAD		:= (cAli)->B1_LOCPAD
                        SB1->B1_POSIPI		:= (cAli)->B1_POSIPI
                        SB1->B1_ESPECIE		:= (cAli)->B1_ESPECIE
                        SB1->B1_EX_NCM		:= (cAli)->B1_EX_NCM
                        SB1->B1_EX_NBM		:= (cAli)->B1_EX_NBM
                        SB1->B1_GRUPO		:= (cAli)->B1_GRUPO	
                        SB1->B1_PICM		:= (cAli)->B1_PICM	
                        SB1->B1_SEGUM		:= (cAli)->B1_SEGUM	
                        SB1->B1_ONU			:= (cAli)->B1_ONU		
                        SB1->B1_CODTKE		:= (cAli)->B1_CODTKE
                        SB1->B1_TE			:= (cAli)->B1_TE		
                        SB1->B1_IPI			:= (cAli)->B1_IPI		
                        SB1->B1_TS			:= (cAli)->B1_TS		
                        SB1->B1_ALIQISS		:= (cAli)->B1_ALIQISS
                        SB1->B1_CODISS		:= (cAli)->B1_CODISS
                        SB1->B1_PICMRET		:= (cAli)->B1_PICMRET
                        SB1->B1_PICMENT		:= (cAli)->B1_PICMENT
                        SB1->B1_UCOM		:= Stod((cAli)->B1_UCOM) //(cAli)->B1_UCOM	
                        SB1->B1_IMPZFRC		:= (cAli)->B1_IMPZFRC
                        SB1->B1_CONV		:= (cAli)->B1_CONV	
                        SB1->B1_ESTFOR		:= (cAli)->B1_ESTFOR
                        SB1->B1_TIPCONV		:= (cAli)->B1_TIPCONV
                        SB1->B1_ALTER		:= (cAli)->B1_ALTER	
                        SB1->B1_QE			:= (cAli)->B1_QE		
                        SB1->B1_PRV1		:= (cAli)->B1_PRV1	
                        SB1->B1_EMIN		:= (cAli)->B1_EMIN	
                        SB1->B1_CUSTD		:= (cAli)->B1_CUSTD	
                        SB1->B1_MCUSTD		:= (cAli)->B1_MCUSTD
                        SB1->B1_UPRC		:= (cAli)->B1_UPRC	
                        SB1->B1_UPRC2		:= (cAli)->B1_UPRC2	
                        SB1->B1_CUTFA		:= (cAli)->B1_CUTFA	
                        SB1->B1_PESO		:= (cAli)->B1_PESO	
                        SB1->B1_ESTSEG		:= (cAli)->B1_ESTSEG
                        SB1->B1_LOJPROC		:= (cAli)->B1_LOJPROC
                        SB1->B1_FORPRZ		:= (cAli)->B1_FORPRZ
                        SB1->B1_PE			:= (cAli)->B1_PE		
                        SB1->B1_TIPE		:= (cAli)->B1_TIPE	
                        SB1->B1_LE			:= (cAli)->B1_LE		
                        SB1->B1_LM			:= (cAli)->B1_LM		
                        SB1->B1_CONTA		:= (cAli)->B1_CONTA	
                        SB1->B1_DATREF		:= Stod((cAli)->B1_DATREF)  //(cAli)->B1_DATREF
                        SB1->B1_CTAREC		:= (cAli)->B1_CTAREC
                        SB1->B1_TOLER		:= (cAli)->B1_TOLER	
                        SB1->B1_UREV		:= Stod((cAli)->B1_UREV) //(cAli)->B1_UREV	
                        SB1->B1_ITEMCC		:= (cAli)->B1_ITEMCC
                        SB1->B1_CC			:= (cAli)->B1_CC		
                        SB1->B1_DTREFP1		:= Stod((cAli)->B1_DTREFP1)  //(cAli)->B1_DTREFP1
                        SB1->B1_CTADESP		:= (cAli)->B1_CTADESP
                        SB1->B1_FAMILIA		:= (cAli)->B1_FAMILIA
                        SB1->B1_QB			:= (cAli)->B1_QB		
                        SB1->B1_APROPRI		:= (cAli)->B1_APROPRI
                        SB1->B1_CONTSOC		:= (cAli)->B1_CONTSOC
                        SB1->B1_FANTASM		:= (cAli)->B1_FANTASM
                        SB1->B1_CONINI		:= Stod((cAli)->B1_CONINI) //(cAli)->B1_CONINI
                        SB1->B1_TIPODEC		:= (cAli)->B1_TIPODEC
                        SB1->B1_CODBAR		:= (cAli)->B1_CODBAR
                        SB1->B1_FPCOD		:= (cAli)->B1_FPCOD	
                        SB1->B1_DESC_P		:= (cAli)->B1_DESC_P
                        SB1->B1_ORIGEM		:= (cAli)->B1_ORIGEM
                        SB1->B1_DESC_GI		:= (cAli)->B1_DESC_GI
                        SB1->B1_DESC_I		:= (cAli)->B1_DESC_I
                        SB1->B1_CLASFIS		:= (cAli)->B1_CLASFIS
                        SB1->B1_FORAEST		:= (cAli)->B1_FORAEST
                        SB1->B1_OPC			:= (cAli)->B1_OPC		
                        SB1->B1_CODOBS		:= (cAli)->B1_CODOBS
                        SB1->B1_FABRIC		:= (cAli)->B1_FABRIC
                        SB1->B1_MONO		:= (cAli)->B1_MONO	
                        SB1->B1_COMIS		:= (cAli)->B1_COMIS	
                        SB1->B1_MRP			:= (cAli)->B1_MRP		
                        SB1->B1_PERINV		:= (cAli)->B1_PERINV
                        SB1->B1_PRODPAI		:= (cAli)->B1_PRODPAI
                        SB1->B1_GRTRIB		:= (cAli)->B1_GRTRIB
                        SB1->B1_NOTAMIN		:= (cAli)->B1_NOTAMIN
                        SB1->B1_NUMCOP		:= (cAli)->B1_NUMCOP
                        SB1->B1_IMPORT		:= (cAli)->B1_IMPORT
                        SB1->B1_IRRF		:= (cAli)->B1_IRRF	
                        SB1->B1_VLREFUS		:= (cAli)->B1_VLREFUS
                        SB1->B1_SITPROD		:= (cAli)->B1_SITPROD
                        SB1->B1_NALNCCA		:= (cAli)->B1_NALNCCA
                        SB1->B1_MODELO		:= (cAli)->B1_MODELO
                        SB1->B1_SETOR		:= (cAli)->B1_SETOR	
                        SB1->B1_NALSH		:= (cAli)->B1_NALSH	
                        SB1->B1_BALANCA		:= (cAli)->B1_BALANCA
                        SB1->B1_TECLA		:= (cAli)->B1_TECLA	
                        SB1->B1_NUMCQPR		:= (cAli)->B1_NUMCQPR
                        SB1->B1_CONTCQP		:= (cAli)->B1_CONTCQP
                        SB1->B1_REVATU		:= (cAli)->B1_REVATU
                        SB1->B1_INSS		:= (cAli)->B1_INSS	
                        SB1->B1_CODEMB		:= (cAli)->B1_CODEMB
                        SB1->B1_ESPECIF		:= (cAli)->B1_ESPECIF
                        SB1->B1_MAT_PRI		:= (cAli)->B1_MAT_PRI
                        SB1->B1_REDINSS		:= (cAli)->B1_REDINSS
                        SB1->B1_ALADI		:= (cAli)->B1_ALADI	
                        SB1->B1_REDIRRF		:= (cAli)->B1_REDIRRF
                        SB1->B1_GRUDES		:= (cAli)->B1_GRUDES
                        SB1->B1_PCSLL		:= (cAli)->B1_PCSLL	
                        SB1->B1_PCOFINS		:= (cAli)->B1_PCOFINS
                        SB1->B1_PPIS		:= (cAli)->B1_PPIS	
                        SB1->B1_MIDIA		:= (cAli)->B1_MIDIA	
                        SB1->B1_QTMIDIA		:= (cAli)->B1_QTMIDIA
                        SB1->B1_ENVOBR		:= (cAli)->B1_ENVOBR
                        SB1->B1_SERIE		:= (cAli)->B1_SERIE	
                        SB1->B1_FAIXAS		:= (cAli)->B1_FAIXAS
                        SB1->B1_CORPRI		:= (cAli)->B1_CORPRI
                        SB1->B1_NROPAG		:= (cAli)->B1_NROPAG
                        SB1->B1_ISBN		:= (cAli)->B1_ISBN	
                        SB1->B1_ATRIB1		:= (cAli)->B1_ATRIB1
                        SB1->B1_TITORIG		:= (cAli)->B1_TITORIG
                        SB1->B1_ATRIB2		:= (cAli)->B1_ATRIB2
                        SB1->B1_ATRIB3		:= (cAli)->B1_ATRIB3
                        SB1->B1_LINGUA		:= (cAli)->B1_LINGUA
                        SB1->B1_CTAPIS		:= (cAli)->B1_CTAPIS
                        SB1->B1_EDICAO		:= (cAli)->B1_EDICAO
                        SB1->B1_BITMAP		:= (cAli)->B1_BITMAP
                        SB1->B1_CORSEC		:= (cAli)->B1_CORSEC
                        SB1->B1_NICONE		:= (cAli)->B1_NICONE
                        SB1->B1_GRADE		:= (cAli)->B1_GRADE	
                        SB1->B1_CTACOFI		:= (cAli)->B1_CTACOFI
                        SB1->B1_FORMLOT		:= (cAli)->B1_FORMLOT
                        SB1->B1_OBSISBN		:= (cAli)->B1_OBSISBN
                        SB1->B1_CONTRAT		:= (cAli)->B1_CONTRAT
                        SB1->B1_ANUENTE		:= (cAli)->B1_ANUENTE
                        SB1->B1_REDPIS		:= (cAli)->B1_REDPIS
                        SB1->B1_REDCOF		:= (cAli)->B1_REDCOF
                        SB1->B1_CLVL		:= (cAli)->B1_CLVL	
                        SB1->B1_ATIVO		:= (cAli)->B1_ATIVO	
                        SB1->B1_DATASUB		:= Stod((cAli)->B1_DATASUB)  //(cAli)->B1_DATASUB
                        SB1->B1_VLRSELO		:= (cAli)->B1_VLRSELO
                        SB1->B1_CODNOR		:= (cAli)->B1_CODNOR
                        SB1->B1_RASTRO		:= (cAli)->B1_RASTRO
                        SB1->B1_PRVALID		:= (cAli)->B1_PRVALID
                        SB1->B1_LOCALIZ		:= (cAli)->B1_LOCALIZ
                        SB1->B1_OPERPAD		:= (cAli)->B1_OPERPAD
                        SB1->B1_TIPOCQ		:= (cAli)->B1_TIPOCQ
                        SB1->B1_SOLICIT		:= (cAli)->B1_SOLICIT
                        SB1->B1_REGSEQ		:= (cAli)->B1_REGSEQ
                        SB1->B1_PESBRU		:= (cAli)->B1_PESBRU
                        SB1->B1_GRUPCOM		:= (cAli)->B1_GRUPCOM
                        SB1->B1_TAB_IPI		:= (cAli)->B1_TAB_IPI
                        SB1->B1_MTBF		:= (cAli)->B1_MTBF	
                        SB1->B1_MTTR		:= (cAli)->B1_MTTR	
                        SB1->B1_FLAGSUG		:= (cAli)->B1_FLAGSUG
                        SB1->B1_CLASSVE		:= (cAli)->B1_CLASSVE
                        SB1->B1_VLR_IPI		:= (cAli)->B1_VLR_IPI
                        SB1->B1_TIPCAR		:= (cAli)->B1_TIPCAR
                        SB1->B1_VLR_ICM		:= (cAli)->B1_VLR_ICM
                        SB1->B1_VLSOL		:= (cAli)->B1_VLSOL	
                        SB1->B1_CODPAD		:= (cAli)->B1_CODPAD
                        SB1->B1_SITUAC		:= (cAli)->B1_SITUAC
                        SB1->B1_PESOB		:= (cAli)->B1_PESOB	
                        SB1->B1_CODFOR		:= (cAli)->B1_CODFOR
                        SB1->B1_MEDCON		:= (cAli)->B1_MEDCON
                        SB1->B1_ICMS		:= (cAli)->B1_ICMS	
                        SB1->B1_VLPER		:= (cAli)->B1_VLPER	
                        SB1->B1_COMTV		:= (cAli)->B1_COMTV	
                        SB1->B1_REQUIS		:= (cAli)->B1_REQUIS
                        SB1->B1_TRIBUTA		:= (cAli)->B1_TRIBUTA
                        SB1->B1_COMISS		:= (cAli)->B1_COMISS
                        SB1->B1_CODANT		:= (cAli)->B1_CODANT
                        SB1->B1_EMBALA		:= (cAli)->B1_EMBALA
                        SB1->B1_UCALSTD		:= Stod((cAli)->B1_UCALSTD) //(cAli)->B1_UCALSTD
                        SB1->B1_CPOTENC		:= (cAli)->B1_CPOTENC
                        SB1->B1_POTENCI		:= (cAli)->B1_POTENCI
                        SB1->B1_QTDACUM		:= (cAli)->B1_QTDACUM
                        SB1->B1_QTDINIC		:= (cAli)->B1_QTDINIC
                        SB1->B1_BASICMS		:= (cAli)->B1_BASICMS
                        SB1->B1_ALIQICM		:= (cAli)->B1_ALIQICM
                        SB1->B1_SITUACA		:= (cAli)->B1_SITUACA
                        SB1->B1_CODVELH		:= (cAli)->B1_CODVELH
                        SB1->B1_CODNOVO		:= (cAli)->B1_CODNOVO
                        SB1->B1_COFINS		:= (cAli)->B1_COFINS
                        SB1->B1_CTADEV		:= (cAli)->B1_CTADEV
                        SB1->B1_GERAOP		:= (cAli)->B1_GERAOP
                        SB1->B1_USERLGA		:= (cAli)->B1_USERLGA
                        SB1->B1_USERLGI		:= (cAli)->B1_USERLGI
                        SB1->B1_PIS			:= (cAli)->B1_PIS		
                        SB1->B1_CSLL		:= (cAli)->B1_CSLL	
                        SB1->B1_SELO		:= (cAli)->B1_SELO	
                        SB1->B1_LOTVEN		:= (cAli)->B1_LOTVEN
                        SB1->B1_OK			:= (cAli)->B1_OK		
                        SB1->B1_AGMRKP		:= (cAli)->B1_AGMRKP
                        SB1->B1_TPEMIN		:= (cAli)->B1_TPEMIN
                        SB1->B1_MARKUP		:= (cAli)->B1_MARKUP
                        SB1->B1_MSBLQL		:= "1" // Produto copiado nasce bloqueado
                        SB1->B1_EMAX		:= (cAli)->B1_EMAX	
                        SB1->B1_UMOEC		:= (cAli)->B1_UMOEC	
                        SB1->B1_UVLRC		:= (cAli)->B1_UVLRC	
                        SB1->B1_CTAICMS		:= (cAli)->B1_CTAICMS
                        SB1->B1_DESCAUX		:= (cAli)->B1_DESCAUX
                        SB1->B1_USAFEFO		:= (cAli)->B1_USAFEFO
                        SB1->B1_AGREGCU		:= (cAli)->B1_AGREGCU
                        SB1->B1_CRDEST		:= (cAli)->B1_CRDEST
                        SB1->B1_QUADPRO		:= (cAli)->B1_QUADPRO
                        SB1->B1_FRACPER		:= (cAli)->B1_FRACPER
                        SB1->B1_INT_ICM		:= (cAli)->B1_INT_ICM
                        SB1->B1_FRETISS		:= (cAli)->B1_FRETISS
                        SB1->B1_CNAE		:= (cAli)->B1_CNAE	
                        SB1->B1_RETOPER		:= (cAli)->B1_RETOPER
                        SB1->B1_CDSCANC		:= (cAli)->B1_CDSCANC
                        SB1->B1_TPREG		:= (cAli)->B1_TPREG	
                        SB1->B1_CALCFET		:= (cAli)->B1_CALCFET
                        SB1->B1_PAUTFET		:= (cAli)->B1_PAUTFET
                        SB1->B1_PRFDSUL		:= (cAli)->B1_PRFDSUL
                        SB1->B1_VLR_PIS		:= (cAli)->B1_VLR_PIS
                        SB1->B1_VLR_COF		:= (cAli)->B1_VLR_COF
                        SB1->B1_GCCUSTO		:= (cAli)->B1_GCCUSTO
                        SB1->B1_CCCUSTO		:= (cAli)->B1_CCCUSTO
                        SB1->B1_BASEIST		:= (cAli)->B1_BASEIST
                        SB1->B1_FECP		:= (cAli)->B1_FECP	
                        SB1->B1_DESPIMP		:= (cAli)->B1_DESPIMP
                        SB1->B1_CLASSE		:= (cAli)->B1_CLASSE
                        SB1->B1_CODANP		:= (cAli)->B1_CODANP
                        SB1->B1_CODIF		:= (cAli)->B1_CODIF	
                        SB1->B1_CODSIMP		:= (cAli)->B1_CODSIMP
                        SB1->B1_PARCEI		:= (cAli)->B1_PARCEI
                        SB1->B1_PMACNUT		:= (cAli)->B1_PMACNUT
                        SB1->B1_PMICNUT		:= (cAli)->B1_PMICNUT
                        SB1->B1_CODQAD		:= (cAli)->B1_CODQAD
                        SB1->B1_QBP			:= (cAli)->B1_QBP		
                        SB1->B1_FETHAB		:= (cAli)->B1_FETHAB
                        SB1->B1_VOLSIMP		:= (cAli)->B1_VOLSIMP
                        SB1->B1_BASE		:= (cAli)->B1_BASE	
                        SB1->B1_DTPRCAN		:= Stod((cAli)->B1_DTPRCAN)  //(cAli)->B1_DTPRCAN
                        SB1->B1_PRCANT		:= (cAli)->B1_PRCANT
                        SB1->B1_ALTTKE		:= (cAli)->B1_ALTTKE
                        SB1->B1_RPRODEP		:= (cAli)->B1_RPRODEP
                        SB1->B1_SELOEN		:= (cAli)->B1_SELOEN
                        SB1->B1_ALFECOP		:= (cAli)->B1_ALFECOP
                        SB1->B1_ALFECST		:= (cAli)->B1_ALFECST
                        SB1->B1_FECOP		:= (cAli)->B1_FECOP	
                        SB1->B1_ALFUMAC		:= (cAli)->B1_ALFUMAC
                        SB1->B1_CRICMS		:= (cAli)->B1_CRICMS
                        SB1->B1_PRODREC		:= (cAli)->B1_PRODREC
                        SB1->B1_TRIBMUN		:= (cAli)->B1_TRIBMUN
                        SB1->B1_VIGENC		:= Stod((cAli)->B1_VIGENC)//(cAli)->B1_VIGENC
                        SB1->B1_DTCORTE		:= Stod((cAli)->B1_DTCORTE)  //(cAli)->B1_DTCORTE
                        SB1->B1_CRDPRES		:= (cAli)->B1_CRDPRES
                        SB1->B1_AFETHAB		:= (cAli)->B1_AFETHAB
                        SB1->B1_AFACS		:= (cAli)->B1_AFACS	
                        SB1->B1_AFABOV		:= (cAli)->B1_AFABOV
                        SB1->B1_TFETHAB		:= (cAli)->B1_TFETHAB
                        SB1->B1_REFBAS		:= (cAli)->B1_REFBAS
                        SB1->B1_TPPROD		:= (cAli)->B1_TPPROD
                        SB1->B1_PRN944I		:= (cAli)->B1_PRN944I
                        SB1->B1_VEREAN		:= (cAli)->B1_VEREAN
                        SB1->B1_IVAAJU		:= (cAli)->B1_IVAAJU
                        SB1->B1_FUSTF		:= (cAli)->B1_FUSTF	
                        SB1->B1_REGRISS		:= (cAli)->B1_REGRISS
                        SB1->B1_PRDORI		:= (cAli)->B1_PRDORI	
                        SB1->B1_ESCRIPI		:= (cAli)->B1_ESCRIPI
                        SB1->B1_RICM65		:= (cAli)->B1_RICM65
                        SB1->B1_CFEM		:= (cAli)->B1_CFEM	
                        SB1->B1_CFEMS		:= (cAli)->B1_CFEMS	
                        SB1->B1_CFEMA		:= (cAli)->B1_CFEMA	
                        SB1->B1_CODLAN		:= (cAli)->B1_CODLAN
                        SB1->B1_TNATREC		:= (cAli)->B1_TNATREC
                        SB1->B1_REGESIM		:= (cAli)->B1_REGESIM
                        SB1->B1_CNATREC		:= (cAli)->B1_CNATREC
                        SB1->B1_GRPNATR		:= (cAli)->B1_GRPNATR
                        SB1->B1_DTFIMNT		:= Stod((cAli)->B1_DTFIMNT)  //(cAli)->B1_DTFIMNT
                        SB1->B1_FECPBA		:= (cAli)->B1_FECPBA
                        SB1->B1_CRICMST		:= (cAli)->B1_CRICMST
                        SB1->B1_DIFCNAE		:= (cAli)->B1_DIFCNAE
                        SB1->B1_PR43080		:= (cAli)->B1_PR43080
                        SB1->B1_DCI			:= (cAli)->B1_DCI		
                        SB1->B1_DCRE		:= (cAli)->B1_DCRE	
                        SB1->B1_DCR			:= (cAli)->B1_DCR		
                        SB1->B1_DCRII		:= (cAli)->B1_DCRII	
                        SB1->B1_COEFDCR		:= (cAli)->B1_COEFDCR
                        SB1->B1_PRINCMG		:= (cAli)->B1_PRINCMG
                        SB1->B1_ALFECRN		:= (cAli)->B1_ALFECRN
                        SB1->B1_CHASSI		:= (cAli)->B1_CHASSI
                        SB1->B1_EXPORTA		:= (cAli)->B1_EXPORTA
                        SB1->B1_FSHELL		:= (cAli)->B1_FSHELL
                        SB1->B1_MPALLET		:= (cAli)->B1_MPALLET
                        SB1->B1_PREMIUM		:= (cAli)->B1_PREMIUM
                        SB1->B1_VOLUME		:= (cAli)->B1_VOLUME
                        SB1->B1_JAS			:= (cAli)->B1_JAS		
                        SB1->B1_JAE			:= (cAli)->B1_JAE		
                        SB1->B1_MSEXP		:= (cAli)->B1_MSEXP	
                        SB1->B1_ULTAFV		:= Stod((cAli)->B1_ULTAFV)  //(cAli)->B1_ULTAFV
                        SB1->B1_NAODER		:= (cAli)->B1_NAODER
                        SB1->B1_CABCMIN		:= (cAli)->B1_CABCMIN
                        SB1->B1_CABCMAX		:= (cAli)->B1_CABCMAX
                        SB1->B1_FAMAGR		:= (cAli)->B1_FAMAGR
                        SB1->B1_BASTSC		:= (cAli)->B1_BASTSC
                        SB1->B1_HELIX		:= (cAli)->B1_HELIX	
                        SB1->B1_SINTETI		:= (cAli)->B1_SINTETI
                        SB1->B1_TAXA		:= (cAli)->B1_TAXA	
                        SB1->B1_TIER		:= (cAli)->B1_TIER	
                        SB1->B1_CODFILT		:= (cAli)->B1_CODFILT
                        SB1->B1_PONTOS		:= (cAli)->B1_PONTOS
                        SB1->B1_DTCAD		:= Stod((cAli)->B1_DTCAD) //(cAli)->B1_DTCAD	
                        SB1->B1_EMBTKE		:= (cAli)->B1_EMBTKE
                        SB1->B1_ORIGIMP		:= (cAli)->B1_ORIGIMP
                        SB1->B1_PRODSIG		:= (cAli)->B1_PRODSIG
                        SB1->B1_AJUDIF		:= (cAli)->B1_AJUDIF
                        SB1->B1_RSATIVO		:= (cAli)->B1_RSATIVO
                        SB1->B1_DESBSE3		:= (cAli)->B1_DESBSE3
                        SB1->B1_BASE3		:= (cAli)->B1_BASE3	
                        SB1->B1_IAT			:= (cAli)->B1_IAT		
                        SB1->B1_IPPT		:= (cAli)->B1_IPPT	
                        SB1->B1_SITTRIB		:= (cAli)->B1_SITTRIB
                        SB1->B1_TALLA		:= (cAli)->B1_TALLA	
                        SB1->B1_CODPROC		:= (cAli)->B1_CODPROC
                        SB1->B1_GDODIF		:= (cAli)->B1_GDODIF
                        SB1->B1_VLCIF		:= (cAli)->B1_VLCIF	
                        SB1->B1_PRODSBP		:= (cAli)->B1_PRODSBP
                        SB1->B1_VALEPRE		:= (cAli)->B1_VALEPRE
                        SB1->B1_LOTESBP		:= (cAli)->B1_LOTESBP
                        SB1->B1_TIPOBN		:= (cAli)->B1_TIPOBN
                        SB1->B1_DESBSE2		:= (cAli)->B1_DESBSE2
                        SB1->B1_CARGAE		:= (cAli)->B1_CARGAE
                        SB1->B1_ADMIN		:= (cAli)->B1_ADMIN	
                        SB1->B1_BASE2		:= (cAli)->B1_BASE2	
                        SB1->B1_GARANT		:= (cAli)->B1_GARANT
                        SB1->B1_TIPVEC		:= (cAli)->B1_TIPVEC
                        SB1->B1_PERGART		:= (cAli)->B1_PERGART
                        SB1->B1_ESTRORI		:= (cAli)->B1_ESTRORI
                        SB1->B1_COLOR		:= (cAli)->B1_COLOR	
                        SB1->B1_TPDP		:= (cAli)->B1_TPDP	
                        SB1->B1_IMPNCM		:= (cAli)->B1_IMPNCM
                        SB1->B1_MEPLES		:= (cAli)->B1_MEPLES
                        SB1->B1_FEMB		:= (cAli)->B1_FEMB	
                        SB1->B1_DESCMAX		:= (cAli)->B1_DESCMAX
                        SB1->B1_PORCPRL		:= (cAli)->B1_PORCPRL
                        SB1->B1_AFAMAD		:= (cAli)->B1_AFAMAD
                        SB1->B1_ZZBLQ20		:= (cAli)->B1_ZZBLQ20
                        SB1->B1_XRUA		:= (cAli)->B1_XRUA	
                        SB1->B1_XBLOCO		:= (cAli)->B1_XBLOCO
                        SB1->B1_XNIVEL		:= (cAli)->B1_XNIVEL
                        SB1->B1_XAPTO		:= (cAli)->B1_XAPTO	
                        SB1->B1_XLOCAL1		:= (cAli)->B1_XLOCAL1
                        SB1->B1_XLOCAL2		:= (cAli)->B1_XLOCAL2
                        SB1->B1_XLOCAL3		:= (cAli)->B1_XLOCAL3
                        SB1->B1_AFASEMT		:= (cAli)->B1_AFASEMT
                        SB1->B1_XLOCAL4		:= (cAli)->B1_XLOCAL4
                        SB1->B1_PMGRCTB		:= (cAli)->B1_PMGRCTB
                        SB1->B1_TROCA		:= (cAli)->B1_TROCA	
                        SB1->B1_GRPTI		:= (cAli)->B1_GRPTI	
                        SB1->B1_GRPCST		:= (cAli)->B1_GRPCST
                        SB1->B1_CEST		:= (cAli)->B1_CEST	
                        SB1->B1_AFUNDES		:= (cAli)->B1_AFUNDES
                        SB1->B1_HREXPO		:= (cAli)->B1_HREXPO
                        SB1->B1_PAFMD5		:= (cAli)->B1_PAFMD5
                        SB1->B1_IDHIST		:= (cAli)->B1_IDHIST
                        SB1->B1_CODGTIN		:= (cAli)->B1_CODGTIN
                        SB1->B1_XROYALT		:= (cAli)->B1_XROYALT
                        SB1->B1_AIMAMT		:= (cAli)->B1_AIMAMT
                        SB1->B1_TERUM		:= (cAli)->B1_TERUM	
                        SB1->B1_INTEG		:= (cAli)->B1_INTEG	
                        SB1->B1_ZZAPLIC		:= (cAli)->B1_ZZAPLIC
                        SB1->B1_QTDSER		:= (cAli)->B1_QTDSER
                        SB1->B1_APOPRO		:= (cAli)->B1_APOPRO
                    MsUnlock()
                aAdd(aLog[Len(aLog)], Padr((cAli)->B1_COD,15) + Padr(cFilDest,6))

				Logs("Produto: " + (cAli)->B1_COD)
				Logs("Filial Destino: " + cFilDest)
				Logs("==============================================================")
                EndIf
                IncProc()
                (cAli)->(DbSkip())
            EndDo
                If MsgYesNo("Deseja imprimir o relatório dos produtos copiados?", "XAG0088")		           
                 fMakeLog( aLog , aTitle , NIL  , .T. , "XAG0088" , NIL , NIL, NIL, NIL, .F. )
	            Endif
        Else
            FWAlertError("Não existem produtos a copiar para as filiais informadas!!!", "AGRICOPEL")   
        EndIf
Return

/*
* Geração do arquivo de log.
* @Author Geyson Albano
* @Data 10/06/2020
*/
Static Function Logs(cTexto)
	Local cCodLog	:= SubStr(DtoS(Date()),1,6)
	Local cPasta	:= "\log\XAG0088"
	Local FC_NORMAL := 0

	ConOut(DtoC(Date(),"dd/mm/yy")+"|"+Time()+"|"+cUserName+"| "+cTexto)

	FWMakeDir(cPasta)
	If File(cPasta+"\"+cCodLog+".txt")
		nHdl := FOpen(cPasta+"\"+cCodLog+".txt" , 2 + 64 )
	Else
		nHdl := FCreate(cPasta+"\"+cCodLog+".txt",FC_NORMAL)
	EndIf
	FSeek(nHdl, 0, 2)
	FWrite(nHdl, DtoC(Date(),"dd/mm/yy")+"|"+Time()+"|"+cUserName+"| "+cTexto+CRLF )

	FClose(nHdl)
Return
