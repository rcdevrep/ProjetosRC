#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"         
#INCLUDE "TOPCONN.CH"    
#INCLUDE "Protheus.ch"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "TBICONN.CH"


User Function AGX617() 
Local aParam  := {}    

If !Used() 
     PREPARE ENVIRONMENT EMPRESA "01" FILIAL "06" MODULO "FAT"      
     CONOUT("ANTES DO SHEA301I")     
     CONOUT("VAISS")
     
     
     AADD(aParam,.T.)   
     AADD(aParam,"01")   
     AADD(aParam,"06")   
     
     
     U_SHEA301I(aParam)
     
     RESET ENVIRONMENT
     
     
Endif 


Return()