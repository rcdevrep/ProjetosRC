#INCLUDE "PROTHEUS.CH"



User Function XAG0110( _aParms )

    Default _aParms := {"15","01"}

    RPCSetType(3)
    RPCSetEnv(_aParms[1],_aParms[2],"","","","",{})

    u_atuZLE()

    RpcClearEnv()

Return



user function atuZLE(cArq)

    local cDir := getNewPar('MV_XPTHDWL', '\\192.168.1.118\CombusMonitor\DB\')
    local nDiasArq := getNewPar('MV_XDIASAR', 2)
    local aArqs := {}
    local iAux   
    local cLinha := ''
    local aLinha := {}
    
    default cArq := ''  //Quando quiser importar somente um arquivo, manda preenchido o nome dele.



    if !empty(cArq)
        aadd(aArqs, {UPPER(cArq),,,,'A'})
    else
        aArqs := directory(cDir + '*.dat')
    endif

    if len(aArqs) > 0

        for iAux := 1 to len(aArqs)

            if aArqs[iAux][5] == 'A'

                ZLE->(dbSetOrder(2))  //ZLE_ARQNOM

                if ZLE->(msSeek(alltrim(aArqs[iAux][1])))
                    
                    if aArqs[iAux][3] >= date() - nDiasArq

                        while !ZLE->(eof()) .and. alltrim(ZLE->ZLE_ARQNOM) == alltrim(aArqs[iAux][1])

                            ZLE->(recLock('ZLE', .F.))
                            ZLE->(dbDelete())
                            ZLE->(msUnlock())

                            ZLE->(dbSkip())

                        enddo

                    endif

                endif


                if ! ZLE->(msSeek(alltrim(aArqs[iAux][1])))

                    conout('----> atuZLE() - Arquivo: ' + cDir + aArqs[iAux][1])

                    ft_fUse(cDir + aArqs[iAux][1])
                    while ! ft_fEof()

                        cLinha := ft_fReadLn()
                        aLinha := strTokArr3(cLinha, ";")

                        ZLE->(recLock('ZLE',.t.))

                        ZLE->ZLE_FILIAL := xfilial('ZLE')
                        ZLE->ZLE_ARQNOM := aArqs[iAux][1]
                        ZLE->ZLE_STATUS := iif(aLinha[1]=='true',.t.,.f.)

                        if len(strTokArr3(aLinha[2], ' ')) == 2
                            ZLE->ZLE_DTGERA := cToD(strTokArr3(aLinha[2], ' ')[1])
                            ZLE->ZLE_HRGERA := strTokArr3(aLinha[2], ' ')[2]
                        endif

                        if len(strTokArr3(aLinha[3], '_')) >= 3
                            ZLE->ZLE_DATA   := sToD(strTokArr3(aLinha[3], '_')[1])
                            ZLE->ZLE_PLACA  := strTokArr3(aLinha[3], '_')[2]
                            ZLE->ZLE_VIAGEM := substr(aLinha[3], len(strTokArr3(aLinha[3], '_')[1]) + len(strTokArr3(aLinha[3], '_')[2]) + 3)
                        endif

                        ZLE->ZLE_TICKET := aLinha[4]
                        ZLE->ZLE_MEDIDR := val(aLinha[5])
                        ZLE->ZLE_PROD   := aLinha[6]
                        ZLE->ZLE_VOLPRO := val(aLinha[7])
                        ZLE->ZLE_VOLCAR := val(aLinha[8])
                        ZLE->ZLE_VOLVAR := val(aLinha[9])
                        ZLE->ZLE_TEMP   := val(aLinha[10])
                        ZLE->ZLE_VALOR1 := val(aLinha[11])
                        ZLE->ZLE_VALOR2 := val(aLinha[12])
                        ZLE->ZLE_CLIE   := aLinha[13]
                        ZLE->ZLE_EMPRE  := aLinha[14]
                        ZLE->ZLE_PROG   := 'PROTHEUS'

                        ZLE->(msUnlock())

                        ft_fSkip()

                    enddo
                    ft_fUse()

                endif

            endif

        next iAux

    endif    

return .t.
