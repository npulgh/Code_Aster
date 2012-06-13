      SUBROUTINE MMCYC1(RESOCO,IPTC  ,NOMPT ,INDCO )
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
      CHARACTER*24 RESOCO
      INTEGER      IPTC
      CHARACTER*16 NOMPT
      INTEGER      INDCO
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE)
C
C DETECTION DU CYCLE DE TYPE CONTACT/PAS CONTACT
C
C ----------------------------------------------------------------------
C
C
C IN  RESOCO : SD DE RESOLUTION DU CONTACT
C IN  INDCO  : STATUT DE CONTACT
C IN  NOMPT  : NOM DU POINT DE CONTACT
C IN  IPTC   : NUMERO DE LA LIAISON DE CONTACT
C
C
C
C
      CHARACTER*24 CYCLIS,CYCNBR,CYCTYP,CYCPOI
      INTEGER      JCYLIS,JCYNBR,JCYTYP,JCYPOI
      INTEGER      STATUT(30)
      INTEGER      LONGCY,CCYCLE,NCYCLE,TCYCLE,ICYCL
      CHARACTER*16 LCYCLE
      LOGICAL      ISCYCL
      LOGICAL      DETECT
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      LONGCY = 3
      DETECT = .FALSE.
C
C --- ACCES OBJETS
C
      CYCLIS = RESOCO(1:14)//'.CYCLIS'
      CYCNBR = RESOCO(1:14)//'.CYCNBR'
      CYCTYP = RESOCO(1:14)//'.CYCTYP'
      CYCPOI = RESOCO(1:14)//'.CYCPOI'
      CALL JEVEUO(CYCLIS,'E',JCYLIS)
      CALL JEVEUO(CYCNBR,'E',JCYNBR)
      CALL JEVEUO(CYCTYP,'E',JCYTYP)
      CALL JEVEUO(CYCPOI,'E',JCYPOI)
C
C --- ETAT PRECEDENT
C
      CCYCLE = ZI(JCYLIS-1+4*(IPTC-1)+1)
      NCYCLE = ZI(JCYNBR-1+4*(IPTC-1)+1)
      CALL ISDECO(CCYCLE,STATUT,30)
C
C --- MISE A JOUR
C
      NCYCLE = NCYCLE + 1
      STATUT(NCYCLE) = INDCO
      CALL ISCODE(STATUT,CCYCLE,30)
C
C --- DETECTION D'UN CYCLE
C
      TCYCLE = 0
      LCYCLE = ' '
      IF (NCYCLE.EQ.LONGCY) THEN
        DETECT = ISCYCL(CCYCLE,LONGCY)
        IF (DETECT) THEN
          TCYCLE = 1
          LCYCLE = NOMPT
        ENDIF
      ENDIF
C
      ZI(JCYTYP-1+4*(IPTC-1)+1)   = TCYCLE
      ZK16(JCYPOI-1+4*(IPTC-1)+1) = LCYCLE
C
C --- REINITIALISATION DU CYCLE
C
      IF (NCYCLE.EQ.LONGCY) THEN
        CALL ISDECO(CCYCLE,STATUT,30)
        DO 10 ICYCL = 1,LONGCY-1
          STATUT(ICYCL) = STATUT(ICYCL+1)
  10    CONTINUE
        CALL ISCODE(STATUT,CCYCLE,30)
        NCYCLE = LONGCY - 1
      ENDIF
C
C --- SAUVEGARDE DU CYCLE
C
      ZI(JCYLIS-1+4*(IPTC-1)+1)   = CCYCLE
      ZI(JCYNBR-1+4*(IPTC-1)+1)   = NCYCLE
C
      CALL JEDEMA()
      END
