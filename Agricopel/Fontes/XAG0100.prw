#include "rwmake.ch"
#include "topconn.ch"



//-------------------------------------------------------------------
/*/{Protheus.doc} XAG0100
Fun��o para gerar EDI de produtos
para a Agricopel.
Integra��o Maxton
@author J�nior Conte
@since 23/12/2022
@version 1.0

/*/
//-------------------------------------------------------------------


User Function XAG0100()

AtuSX1()

if cfilAnt <> '19'
    MsgAlert("Rotina Habilitada apenas para a Filial 19", "XAG0100")
    Return
Endif 

If Pergunte("agedisb2",.T.) == .F.
   Return
Endif

geraprodutos(.f.)


Return


//scheduler
user function XAG0100SCH
RpcSetType(3)
RpcSetEnv("01","19")  

//ddatabase :=  stod("20221215")

geraprodutos(.t.)

RPCClearEnv()

return



Static Function geraprodutos(lsch)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cEOL    := CHR(13)+CHR(10)
//Private nHdl    := fCreate(TRIM(MV_PAR03)+".TXT")

Private nTotal       := 0
Private aTotNota     := {}



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a regua de processamento                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lsch
    Processa({|| RunCont(lsch) },"Processando...")
else
    RunCont(lsch)
endif

Return


Static Function RunCont(lsch)

if !lsch
    If MsgYesNo('Deseja salvar diretamente no ftp? ', 'Salvar arquivo')
        _cPath := "\maxton\remessa\new\"
    Else    
        _cPath := cGetFile( "Arquivos de Exportacao Corpem | ",OemToAnsi("Selecione Diretorio"), ,"" ,.T.,GETF_LOCALHARD + GETF_RETDIRECTORY)
    Endif
else
    _cPath := "\maxton\remessa\new\"
endif


_aTotTESCFO := {}

/*
_cQry :=  "SELECT DISTINCT  F2_FILIAL, F2_CLIENTE, F2_LOJA, F2_EMISSAO, F2_DOC, F2_SERIE, D2_PEDIDO, F2_VALBRUT, D2_PEDIDO, A1_NOME, A1_CGC,A1_MUN, A1_CEP, A1_EST, A1_BAIRRO,A1_END, A4_CGC  "
_cQry := _cQry + "FROM " + RETSQLNAME("SF2") + " F2 "
_cQry := _cQry + " INNER JOIN " + RETSQLNAME("SD2") + " D2 ON D2.D2_FILIAL = F2.F2_FILIAL  "
_cQry := _cQry + "      AND D2.D2_DOC  = F2.F2_DOC AND D2.D2_SERIE  = F2.F2_SERIE "
_cQry := _cQry + "      AND D2.D2_CLIENTE  = F2.F2_CLIENTE AND D2.D2_LOJA  = F2.F2_LOJA "
_cQry := _cQry + " INNER JOIN " + RETSQLNAME("SA1") + " A1 ON A1.A1_FILIAL = '"+xFilial("SA1")+"'  "
_cQry := _cQry + "      AND  A1.A1_COD = F2.F2_CLIENTE AND A1.A1_LOJA = F2.F2_LOJA "
_cQry := _cQry + " LEFT JOIN " + RETSQLNAME("SA4") + " A4 ON A4.A4_FILIAL = '"+xFilial("SA4")+"'  "
_cQry := _cQry + "      AND  A4.A4_COD = F2.F2_TRANSP "
_cQry := _cQry + " WHERE F2.D_E_L_E_T_<> '*'  And D2.D_E_L_E_T_<> '*'  And A1.D_E_L_E_T_<> '*'  And A1.D_E_L_E_T_<> '*'  "
_cQry := _cQry +" And F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' And  '"+dtos(MV_PAR02) + "' "
_cQry := _cQry +" And D2_PEDIDO  BETWEEN '"+mv_par03+"' And  '" + MV_PAR04 + "' "
_cQry := _cQry +" And D2_FILIAL  BETWEEN '"+mv_par05+"' And  '" + MV_PAR06 + "' "

*/

_cQry :=  "SELECT  *  "
_cQry := _cQry + "FROM " + RETSQLNAME("SB1") + " B1 "
_cQry := _cQry + " WHERE    B1.D_E_L_E_T_<> '*'     "
IF !lsch
_cQry := _cQry +" And B1_COD   BETWEEN '"+mv_par01+"' And  '" + MV_PAR02 + "' "
ELSE
_cQry := _cQry +" And B1_HREXPO  = ' ' "
ENDIF
_cQry := _cQry +" And B1_FILIAL   = '" + xFilial("SB1") + "'  AND B1_TIPO IN ('SH','LU','AE','PA','QR') "

If Select("PROD") > 0
    dbSelectArea("PROD")                   
    DbCloseArea()
EndIf

//* Cria a Query e da Um Apelido
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQry),"PROD",.F.,.T.)


dbSelectArea("PROD")
dbGotop()

cHeader   := ""

nContador := 0
cLin      := ""  	


dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt,.T.)


WHILE PROD->(!EOF() )  

	

        if empty(cHeader)
        cHeader := "0" + TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99") + SUBSTR(DTOS(DDATABASE), 7, 2) + "/" +  SUBSTR(DTOS(DDATABASE), 5, 2) + "/" + SUBSTR(DTOS(DDATABASE), 1, 4)
        cHeader += TIME() + cEOL
        nContador := nContador + 1
    endif

   

    //******************  REGISTRO CABEÇALHO  *************************************
    cLin := cLin +   "1"  
    cLin := cLin +   TRANSFORM(SM0->M0_CGC , "@R 99.999.999/9999-99")    
    cLin := cLin +   padr(PROD->B1_COD , 20 )			
    cLin := cLin +   padr(SUBSTR(PROD->B1_DESC ,1, 50), 50 )	
    cLin := cLin +   padr(SUBSTR(PROD->B1_CODBAR ,1, 20), 20 )			
    cLin := cLin +   PADR(PROD->B1_UM, 6)
    cLin := cLin +   SPACE(108)	
    cLin := cLin +   "N"
    cLin := cLin +   SPACE(25)
    cLin := cLin +   "0000"
    cLin := cLin +   SPACE(45)
    //cLin := cLin +   padr(strtran(cValTochar(ROUND(PROD->B1_PESBRU, 3)), ".", ""), 18, "0")		
    //cLin := cLin +   padr(strtran(cValTochar(ROUND(PROD->B1_PESO  , 3)), ".", ""), 18, "0")	
    																									// 1
   // cLin := cLin + "2"                        // 2
   // cLin := cLin +  TRANSFORM(SA1->A1_CGC , "@R 99.999.999/9999-99") 
    //cLin := cLin + padr(CABEC->C9_PEDIDO , 10)
   // cLin := cLin + "PED"     	
   // cLin := cLin + padr(CABEC->F2_SERIE , 2)  																							// 3
   // cLin := cLin + SUBSTR(CABEC->C9_DATALIB, 7, 2) + SUBSTR(CABEC->C9_DATALIB, 5, 2) + SUBSTR(CABEC->C9_DATALIB, 1, 4)																							// 4
   	//cLin := cLin + "000000000000001000"    	
    //cLin := cLin + space(18) //"000000000000000000"								// 5
   // cLin := cLin + 	STRZERO(TRANSFORM(CABEC->F2_VALBRUT , "@E 9999999.99"), 10) 	
   
   // cLin := cLin + padr(strtran(cValTochar(CABEC->C9_QTDLIB * CABEC->C9_PRCVEN), ".", ""), 17, "0")																			// 6
    //cLin := cLin + padr(CABEC->D2_PEDIDO , 30)  	
    //cLin := cLin + padr(CABEC->A1_NOME   , 50) 	
    //cLin := cLin + padr(CABEC->A1_CGC    , 14) 	
    //cLin := cLin + padr(CABEC->A1_CEP    , 8) 	
    //cLin := cLin + padr(CABEC->A1_EST     , 2) 	
    //cLin := cLin + padr(CABEC->A1_MUN    , 40) 																							// 7
    //cLin := cLin + padr(CABEC->A1_BAIRRO , 30) 
    //cLin := cLin + padr(CABEC->A1_END    , 60) 
    //cLin := cLin + SPACE(10)
    //cLin := cLin + SPACE(50)
    //cLin := cLin + SPACE(140)
    //cLin := cLin + padr(CABEC->A4_CGC    , 14) 
   																						// 12
    cLin := cLin + cEOL
    //nContTrans:= nContTrans + 1


    nContador := nContador + 1

    dbSelectArea("SB1")
    dbSetOrder(1)
    if dbSeek(xFilial("SB1") +  PROD->B1_COD )
        RecLock("SB1", .F. )
            SB1->B1_HREXPO :=  SUBSTR(TIME(), 1, 5)
        MsUnlock()
    endif

    

    dbSelectArea("PROD")
	PROD->(DbSkip())       

ENDDO

    cLin := cLin + "9" + padl(cValTochar( nContador + 1), 5, "0")  +  cEOL 

    cLin := cHeader + cLin

    nDia := STRZERO(DAY( DATE() ) , 2)
    cMes := ""
    DO CASE

        CASE MONTH(DATE()) == 1
            cMes := "A"
        CASE MONTH(DATE()) == 2
            cMes := "B"
        CASE MONTH(DATE()) == 3
            cMes := "C"
        CASE MONTH(DATE()) == 4
            cMes := "D"
        CASE MONTH(DATE()) == 5
            cMes := "E"
        CASE MONTH(DATE()) == 6
            cMes := "F"
        CASE MONTH(DATE()) == 7
            cMes := "G"
        CASE MONTH(DATE()) == 8
            cMes := "H"
        CASE MONTH(DATE()) == 9
            cMes := "I"
        CASE MONTH(DATE()) == 10
            cMes := "J"
        CASE MONTH(DATE()) == 11
            cMes := "K"
        CASE MONTH(DATE()) == 12
            cMes := "L"

    ENDCASE


    cDtAtu := GetMV("AG_DTMAXTO")

    cSeq   := GetMV("AG_SEQP")

    if alltrim(dtos(ddatabase)) >  alltrim(cDtAtu)
        PutMv("AG_DTMAXTO",DTOS(dDatabase))
        PutMv("AG_SEQP","001")
        cSeq   := GetMV("AG_SEQP")
    else

    // alltrim(dtos(ddatabase)) ==  alltrim(cDtAtu)
        cSeq := soma1(cSeq)
        PutMv("AG_SEQP",cSeq)

    endif

    cAno    := substr( dtos(DDATABASE), 3, 2)
    nHdl    := fCreate(TRIM(_cPath)+ "AG"+ "P" + nDia + cMes + cAno +"."+alltrim(cSeq))
	
	//alert(nHdl)

   
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
    //³ linha montada.                                                      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
        If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
            //Exit
        Endif
    else
       // MsgInfo("Criado arquivo " +TRIM(_cPath)+ ALLTRIM(CABEC->D2_PEDIDO) +".TXT"  , "Corpem")
    endif

    fClose(nHdl)

    U_XAG0099(.T.)
     

    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
//³ cao anterior.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Return



Static Function AtuSX1()
Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local aDados   := {}
Local nI       := 0
Local nJ       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

aAdd( aDados, {'agedisb2','01','Produto de' ,'Produto de', 'Produto de','mv_ch1','C' ,15,0,0,'G','','MV_PAR01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aDados, {'agedisb2','02','Produto ate','Produto ate','Produto Ate','mv_ch2','C',15,0,0,'G','','MV_PAR02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )


//
// Atualizando dicionário
//
dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aDados )
	If !SX1->( dbSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

// Atualiza Helps
AtuSX1Hlp()

RestArea( aAreaDic )
RestArea( aArea )

Return NIL

Static Function AtuSX1Hlp()



Return NIL
