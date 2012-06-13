      SUBROUTINE IMPE81(NOMRES,IMPE,BASEMO)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8  NOMRES, BASEMO
      CHARACTER*19 IMPE
C ----------------------------------------------------------------------
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
C
C     BUT:
C       REMPLIR 
C
C
C     ARGUMENTS:
C     ----------
C
C      ENTREE :
C-------------
C IN   NOMRES    : NOM DE LA SD_RESULTAT
C IN   IMPE      : NOM DE LA MATRICE D'IMPEDANCE
C IN   BASEMO    : NOM DE LA BASE MODALE DE PROJECTION
C
C      SORTIE :
C-------------
C
C ......................................................................
C
C
C
C
      INTEGER      I,J,IER, NBMODE,IADRIF
      INTEGER      LDBLO,LDBLOI,LDDESA,LDDESM,LDDESR,LDREFA,LDREFM
      INTEGER      LDREFR,LDRESA,LDRESM,LDRESR,LDRESI,LDREFI
      INTEGER      NBDEF,NBMODD,NBMODS,NFR,NIM,NTAIL
      INTEGER      NK,NC,NM,LDBLOK,LDBLOC,LDBLOM

      REAL*8       PARTR, PARTI, PARTR0, PARTI0
      REAL*8       AMSO,DPI,FREQ,R8PI 

      CHARACTER*8  K8B, BLANC
      CHARACTER*16 TYPRES, NOMCOM
      CHARACTER*19 IMPINI
      CHARACTER*19 IMPK,IMPM,IMPC
      INTEGER      IARG
C
      DATA BLANC /'        '/
C
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFMAJ()
C
      CALL GETRES(NOMRES,TYPRES,NOMCOM)
      DPI = 2.D0*R8PI()
C
C --- RECUPERATION DES ARGUMENTS DE LA COMMANDE
C
      CALL GETVR8(' ','FREQ_EXTR',1,IARG,1,FREQ,NFR)
      CALL GETVR8(' ','AMOR_SOL',1,IARG,1,AMSO,NFR)
      CALL GETVID(' ','MATR_IMPE_INIT',1,IARG,1,IMPINI,NIM)
      CALL GETVID(' ','MATR_IMPE_RIGI',1,IARG,1,IMPK,NK)
      CALL GETVID(' ','MATR_IMPE_MASS',1,IARG,1,IMPM,NM)
      CALL GETVID(' ','MATR_IMPE_AMOR',1,IARG,1,IMPC,NC)
      IF (NFR.NE.0) AMSO = 2.D0*AMSO
C
      CALL WKVECT(NOMRES//'.MAEL_RAID_REFE','G V K24',2,LDREFR)
      ZK24(LDREFR) = BASEMO
      ZK24(LDREFR+1) = BLANC
      
      CALL WKVECT(NOMRES//'.MAEL_MASS_REFE','G V K24',2,LDREFM)
      ZK24(LDREFM) = BASEMO
      ZK24(LDREFM+1) = BLANC      
      
      CALL WKVECT(NOMRES//'.MAEL_AMOR_REFE','G V K24',2,LDREFA)
      ZK24(LDREFA) = BASEMO
      ZK24(LDREFA+1) = BLANC      

      CALL JEVEUO(BASEMO//'           .REFD','L',IADRIF)
      CALL DISMOI('F','NB_MODES_DYN',BASEMO,'RESULTAT',
     &                      NBMODD,K8B,IER)
      CALL DISMOI('F','NB_MODES_STA',BASEMO,'RESULTAT',
     &                      NBMODS,K8B,IER)
      NBMODE = NBMODD + NBMODS
C
C --- RECUPERATION DES DIMENSIONS DE LA BASE MODALE
C
      NBDEF = NBMODE
C
C --- ALLOCATION DE LA MATRICE RESULTAT
C
      NTAIL = NBDEF* (NBDEF+1)/2
      CALL WKVECT(NOMRES//'.MAEL_RAID_VALE','G V R',NTAIL,LDRESR)
      CALL WKVECT(NOMRES//'.MAEL_MASS_VALE','G V R',NTAIL,LDRESM)      
      CALL WKVECT(NOMRES//'.MAEL_AMOR_VALE','G V R',NTAIL,LDRESA)
C
C
C        BOUCLE SUR LES COLONNES DE LA MATRICE ASSEMBLEE
C
C
      CALL JEVEUO(JEXNUM(IMPE//'.VALM',1),'L',LDBLO)
      IF (NIM.NE.0) CALL JEVEUO(JEXNUM(IMPINI//'.VALM',1),'L',LDBLOI)
      IF (NK.NE.0) CALL JEVEUO(JEXNUM(IMPK//'.VALM',1),'L',LDBLOK)
      IF (NM.NE.0) CALL JEVEUO(JEXNUM(IMPM//'.VALM',1),'L',LDBLOM)
      IF (NC.NE.0) CALL JEVEUO(JEXNUM(IMPC//'.VALM',1),'L',LDBLOC)
      DO 30 I = 1 , NBMODE
C
C --------- BOUCLE SUR LES INDICES VALIDES DE LA COLONNE I
C
         DO 40 J = 1 , I
C
C
           ZR(LDRESR+I*(I-1)/2+J-1) = 0.D0
           ZR(LDRESA+I*(I-1)/2+J-1) = 0.D0
           ZR(LDRESM+I*(I-1)/2+J-1) = 0.D0
           IF (I.GT.NBMODD.AND.J.GT.NBMODD) THEN
C
C ----------- STOCKAGE DANS LE .UALF A LA BONNE PLACE (1 BLOC)
C
             IF ((NK+NM+NC).EQ.0) THEN
               PARTR = DBLE(ZC(LDBLO+I*(I-1)/2+J-1))
               PARTI = DIMAG(ZC(LDBLO+I*(I-1)/2+J-1))
               ZR(LDRESR+I*(I-1)/2+J-1)=PARTR
               ZR(LDRESA+I*(I-1)/2+J-1)=(PARTI-AMSO*PARTR)/(DPI*FREQ)
               IF (NIM.NE.0) THEN
                 PARTR0 = DBLE(ZC(LDBLOI+I*(I-1)/2+J-1))
                 PARTI0 = DIMAG(ZC(LDBLOI+I*(I-1)/2+J-1))
                 ZR(LDRESR+I*(I-1)/2+J-1) = PARTR0
                 ZR(LDRESA+I*(I-1)/2+J-1) = (PARTI-PARTI0)/(DPI*FREQ)
                 ZR(LDRESM+I*(I-1)/2+J-1) = (PARTR0-PARTR)/(DPI*FREQ)**2
               ENDIF
             ELSE
               IF (NK.NE.0) 
     &           ZR(LDRESR+I*(I-1)/2+J-1)=DBLE(ZC(LDBLOK+I*(I-1)/2+J-1))
               IF (NM.NE.0) 
     &           ZR(LDRESM+I*(I-1)/2+J-1)=DBLE(ZC(LDBLOM+I*(I-1)/2+J-1))
               IF (NC.NE.0) 
     &           ZR(LDRESA+I*(I-1)/2+J-1)=DBLE(ZC(LDBLOC+I*(I-1)/2+J-1))
             ENDIF
           ENDIF
C
 40      CONTINUE
 30   CONTINUE
C
C --- CREATION DU .DESC
C
      CALL WKVECT(NOMRES//'.MAEL_RAID_DESC','G V I',3,LDDESR)
      ZI(LDDESR) = 2
      ZI(LDDESR+1) = NBDEF
      ZI(LDDESR+2) = 2
      CALL WKVECT(NOMRES//'.MAEL_MASS_DESC','G V I',3,LDDESM)
      ZI(LDDESM) = 2
      ZI(LDDESM+1) = NBDEF
      ZI(LDDESM+2) = 2
      CALL WKVECT(NOMRES//'.MAEL_AMOR_DESC','G V I',3,LDDESA)
      ZI(LDDESA) = 2
      ZI(LDDESA+1) = NBDEF
      ZI(LDDESA+2) = 2
C     INER
      CALL WKVECT(NOMRES//'.MAEL_INER_REFE','G V K24',2,LDREFI)
      ZK24(LDREFR) = BASEMO
      ZK24(LDREFR+1) = BLANC
      CALL WKVECT(NOMRES//'.MAEL_INER_VALE','G V R',3*NBDEF,LDRESI)
C
      CALL JEDEMA()
      END
