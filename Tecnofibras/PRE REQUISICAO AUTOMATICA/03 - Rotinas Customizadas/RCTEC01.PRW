#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'RWMAKE.CH'
#include "fileio.ch"
#INCLUDE "TOPCONN.CH"

// RC CONSULTORIA
// EVANDRO BURLIN
// ROTINA RCTEC01 - GERAR PRE REQUISICAO VIA JOB 
// PROJETO - PRE REQUISICAO AUTOMATICA
// DATA - 26/08/2024

USER FUNCTION RCTEC01()

    local aSolicit := {}
    local aItens    := {}
    local n1Cnt
    //local lMarkB, lDtNec
    //local BFiltro   := {|| .T.}
    //local lConsSPed, lGeraSC1, lAmzSA
    //local cSldAmzIni, cSldAmzFim
    //local lLtEco, lConsEmp
    //local nAglutSC
    //local lAuto, lEstSeg
    local aRecSCP
    //local lRateio
    local nFind
    local cMail, cBody

        // preenche os parâmetros MV_PARnn com as respostas das perguntas da rotina MATA106
        //Pergunte("MTA106",.F.)

        //lMarkB     := .F.
        //lDtNec     := (MV_PAR01 == 1)
        //BFiltro    :=
        //lConsSPed := (MV_PAR02 == 1)
        //lGeraSC1   := (MV_PAR03 == 1)
        //lAmzSA     := (MV_PAR04 == 1)
        //cSldAmzIni := MV_PAR05
        //cSldAmzFim := MV_PAR06
        //lLtEco     := (MV_PAR07 == 1)
        //lConsEmp   := (MV_PAR08 == 1)
        //nAglutSC   := MV_PAR09
        //lAuto      := .T.
        //lEstSeg    := (MV_PAR10 == 1)
        aRecSCP    := {}
        //lRateio    := .F.

        MaSAPreReq(.F.,.T.,,.F.,.F.,.T.,'01','01',.F.,.F.,'1',.T.,.F.,@aRecSCP,.F.)

        // monta o array com as solicitações e seus itens
        For n1Cnt := 1 to Len(aRecSCP)
            SCP->(dbGoTo(aRecSCP[n1Cnt]))
            aItens := {}
            aAdd(aItens,allTrim(SCP->CP_ITEM))
            aAdd(aItens,allTrim(SCP->CP_DESCRI))
            aAdd(aItens,SCP->CP_QUANT)
        
            nFind := aScan(aSolicit,{|x| x[1] == SCP->CP_NUM })
            If nFind == 0
                aAdd(aSolicit,{})
                aAdd(aSolicit[nPos],allTrim(SCP->CP_NUM))
                aAdd(aSolicit[nPos],allTrim(SCP->CP_SOLICIT))
                aAdd(aSolicit[nPos],UsrRetMail(allTrim(SCP->CP_CODSOLI)))
                aAdd(aSolicit[nPos],SCP->CP_EMISSAO)
                aAdd(aSolicit[nPos],{})
                aAdd(aSolicit[nPos][5],aItens)
                nPos++
            Else
                aAdd(aSolicit[nFind][5],aItens)
            EndIf
        Next n1Cnt
        
        // envia o email
        For n1Cnt := 1 to Len(aSolicit)
            //cBody := A106GerMail(aSolicit[n1Cnt])
            cMail := 'emerson.en@gmail.com' // pode ser obtido de um parâmetro
            //If !MtSendMail({aSolicit[n1Cnt][3]},"Itens disponiveis para retirada",cBody)
            //    conout(FUNNAME() + " | " + DTOS(MSDATE()) + " - " + TIME() + " | Falha ao enviar E-Mail para " + cMail)
            //EndIf
        Next n1Cnt


RETURN
