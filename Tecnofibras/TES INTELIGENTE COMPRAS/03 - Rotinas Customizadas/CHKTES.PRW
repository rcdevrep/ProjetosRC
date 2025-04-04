#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

//RC CONSULTORIA - EVANDRO BURLIN
//CHAMADO NO GATILHO DO CAMPO C7_OPER
//REGRAS DE TES INTELIGENTE - DILCIANE (DEZEMBRO 2024)

USER FUNCTION CHKTES()

    Local cOper := ""
    Local nOper := Ascan(aHeader,{|x|Alltrim(Upper(x[2]))=="C7_OPER"})
    Local nProduto := Ascan(aHeader,{|x|Alltrim(Upper(x[2]))=="C7_PRODUTO"})
    Local nTes := Ascan(aHeader,{|x|Alltrim(Upper(x[2]))=="C7_TES"})
    Local nConta := Ascan(aHeader,{|x|Alltrim(Upper(x[2]))=="C7_CONTA"})
    Local cConta := aCols[n][nConta]

    DBSELECTAREA("SFM")
    DBSETORDER(4)

        IF DBSEEK(xFilial("SFM")+ALLTRIM(cConta))

            cOper := SFM->FM_TIPO


            aCols[n][nTes] := SFM->FM_TE
            //aCols[n][nTes] := MaTesInt(1,cOper,CFORANTAUT,CLOJANTAUT,"F",ALLTRIM(aCols[n][nProduto]))

            //IF EMPTY(aCols[n][nTes])
            //    aCols[n][nTes] := SFM->FM_TE
            //ENDIF
            
            aCols[n][nOper] := cOper

        ENDIF
RETURN .T.

USER FUNCTION CHKTES2(cConta)

    Local cOper := ""
    Local nProduto := Ascan(aHeader,{|x|Alltrim(Upper(x[2]))=="C7_PRODUTO"})
    Local nTes := Ascan(aHeader,{|x|Alltrim(Upper(x[2]))=="C7_TES"})

    DBSELECTAREA("SFM")
    DBSETORDER(4)

        IF DBSEEK(xFilial("SFM")+ALLTRIM(cConta))

            cOper := SFM->FM_TIPO

            aCols[n][nTes] := SFM->FM_TE
            //aCols[n][nTes] := MaTesInt(1,cOper,CFORANTAUT,CLOJANTAUT,"F",aCols[n][nProduto])

           // IF EMPTY(aCols[n][nTes])
           //     aCols[n][nTes] := SFM->FM_TE
           // ENDIF

        ENDIF
RETURN cOper



 

