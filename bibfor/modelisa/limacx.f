      SUBROUTINE LIMACX(CHAR  ,MOTFAC,NDIM  ,NZOCO)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY  
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY  
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR     
C (AT YOUR OPTION) ANY LATER VERSION.                                   
C                                                                       
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT   
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF            
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU      
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                              
C                                                                       
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE     
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,         
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8  CHAR  
      CHARACTER*16 MOTFAC      
      INTEGER      NZOCO,NDIM         
C     
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE XFEM - LECTURE DONNEES)
C
C LECTURE DES FISSURES EN CONTACT
C      
C ----------------------------------------------------------------------
C
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  MOTFAC : MOT-CLE FACTEUR (VALANT 'CONTACT')
C IN  NDIM   : NOMBRE DE DIMENSIONS DU PROBLEME
C IN  NZOCO  : NOMBRE DE ZONES DE CONTACT
C
C
C
C
      CHARACTER*24 DEFICO
      INTEGER      IOCC,IBID
      CHARACTER*8  FISS
      CHARACTER*24 XFIMAI,NDIMCO
      INTEGER      JFIMAI,JDIM      
      INTEGER      IARG
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      DEFICO = CHAR(1:8)//'.CONTACT' 
C 
C --- ACCES AUX STRUCTURES DE DONNEES DE CONTACT
C 
      NDIMCO = DEFICO(1:16)//'.NDIMCO'    
      CALL JEVEUO(NDIMCO,'E',JDIM)        
C
C --- CREATION DES SD
C        
      XFIMAI = DEFICO(1:16)//'.XFIMAI'     
C 
C --- CREATION DES STRUCTURE DE DONNEES DE CONTACT
C          
      CALL WKVECT(XFIMAI,'G V K8',NZOCO,JFIMAI) 
      ZI(JDIM+1-1) = NDIM
      ZI(JDIM+2-1) = NZOCO
C
C --- LECTURE DES FISSURES EN CONTACT
C
      DO 10 IOCC = 1,NZOCO
        CALL GETVID(MOTFAC,'FISS_MAIT',IOCC,IARG,1,FISS,IBID)
        ZK8(JFIMAI-1+IOCC) = FISS                      
  10  CONTINUE                
C      
      CALL JEDEMA()
      END
