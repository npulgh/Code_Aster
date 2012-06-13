      SUBROUTINE MMCYCZ(DEFICO,RESOCO)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      CHARACTER*24 DEFICO,RESOCO
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE)
C
C DETECTION DES CYCLAGES - REMISE A ZERO DES DETECTEURS
C
C ----------------------------------------------------------------------
C
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  RESOCO : SD POUR LA RESOLUTION DE CONTACT
C
C
C
C
      INTEGER      CFDISI,NTPC,IPTC,ICYC
      CHARACTER*24 CYCLIS,CYCNBR,CYCTYP,CYCPOI,CYCGLI
      INTEGER      JCYLIS,JCYNBR,JCYTYP,JCYPOI,JCYGLI
      LOGICAL      CFDISL,LCTCD,LXFCM
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- FORMULATION
C
      LCTCD  = CFDISL(DEFICO,'FORMUL_DISCRETE')
      LXFCM  = CFDISL(DEFICO,'FORMUL_XFEM')
      IF (LCTCD.OR.LXFCM) GOTO 99
C
C --- ACCES OBJETS
C
      CYCLIS = RESOCO(1:14)//'.CYCLIS'
      CYCNBR = RESOCO(1:14)//'.CYCNBR'
      CYCTYP = RESOCO(1:14)//'.CYCTYP'
      CYCPOI = RESOCO(1:14)//'.CYCPOI'
      CYCGLI = RESOCO(1:14)//'.CYCGLI'
      CALL JEVEUO(CYCLIS,'E',JCYLIS)
      CALL JEVEUO(CYCNBR,'E',JCYNBR)
      CALL JEVEUO(CYCTYP,'E',JCYTYP)
      CALL JEVEUO(CYCPOI,'E',JCYPOI)
      CALL JEVEUO(CYCGLI,'E',JCYGLI)
C
C --- INITIALISATIONS
C
      NTPC   = CFDISI(DEFICO,'NTPC'     )
C
C --- RAZ
C
      DO 50 IPTC = 1,NTPC
        DO 55 ICYC = 1,4
          ZI(JCYLIS-1+4*(IPTC-1)+ICYC)   = 0
          ZI(JCYNBR-1+4*(IPTC-1)+ICYC)   = 0
          ZI(JCYTYP-1+4*(IPTC-1)+ICYC)   = 0
          ZK16(JCYPOI-1+4*(IPTC-1)+ICYC) = ' '
  55    CONTINUE
        ZR(JCYGLI-1+3*(IPTC-1)+1)   = 0.D0
        ZR(JCYGLI-1+3*(IPTC-1)+2)   = 0.D0
        ZR(JCYGLI-1+3*(IPTC-1)+3)   = 0.D0
  50  CONTINUE
C
  99  CONTINUE
C
      CALL JEDEMA()
      END
