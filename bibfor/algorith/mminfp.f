      SUBROUTINE MMINFP(IZONE ,DEFICO,QUESTZ,IREP  ,RREP  ,
     &                  LREP   )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
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
C TOLE CRP_20
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*24  DEFICO
      INTEGER       IZONE
      CHARACTER*(*) QUESTZ
      INTEGER       IREP(*)
      REAL*8        RREP(*)
      LOGICAL       LREP(*)
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (TOUTES METHODES - UTILITAIRE)
C
C REPOND A UNE QUESTION SUR UNE OPTION/CARACTERISTIQUE DU CONTACT
C VARIABLE SUIVANT LA ZONE
C
C ----------------------------------------------------------------------
C
C
C IN  DEFICO : SD POUR LA DEFINITION DU CONTACT
C IN  IZONE  : NUMERO DE LA ZONE DE CONTACT QU'ON INTERROGE
C IN  QUESTI : QUESTION POSEE
C OUT IREP   : VALEUR SI C'EST UN ENTIER
C OUT RREP   : VALEUR SI C'EST UN REEL
C OUT LREP   : VALEUR SI C'EST UN BOOLEEN
C
C
C
C
      INTEGER      IRET
      INTEGER      CFDISI,IFORM,NZOCO
      INTEGER      CFMMVD,ZCMCF,ZMETH,ZTOLE,ZEXCL,ZDIRN,ZCMDF,ZCMXF
      CHARACTER*24 CARACF,CARADF,CARAXF,DIRNOR,METHCO
      INTEGER      JCMCF,JCMDF,JCMXF,JDIRNO,JMETH
      CHARACTER*24 TOLECO,DIRAPP,EXCLFR
      INTEGER      JTOLE,JDIRAP,JEXCLF
      CHARACTER*24 JEUFO1,JEUFO2
      INTEGER      JJFO1,JJFO2
      CHARACTER*8  JEUF1,JEUF2
      CHARACTER*24 QUESTI
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      IREP(1)= 0
      RREP(1)= 0.D0
      LREP(1)= .FALSE.
      QUESTI = QUESTZ
C
C --- ACCES AUX SDS
C
      CARACF = DEFICO(1:16)//'.CARACF'
      CARADF = DEFICO(1:16)//'.CARADF'
      CARAXF = DEFICO(1:16)//'.CARAXF'
      DIRAPP = DEFICO(1:16)//'.DIRAPP'
      DIRNOR = DEFICO(1:16)//'.DIRNOR'
      METHCO = DEFICO(1:16)//'.METHCO'
      TOLECO = DEFICO(1:16)//'.TOLECO'
      EXCLFR = DEFICO(1:16)//'.EXCLFR'
      JEUFO1 = DEFICO(1:16)//'.JFO1CO'
      JEUFO2 = DEFICO(1:16)//'.JFO2CO'
C
      ZMETH  = CFMMVD('ZMETH')
      ZTOLE  = CFMMVD('ZTOLE')
      ZCMCF  = CFMMVD('ZCMCF')
      ZCMDF  = CFMMVD('ZCMDF')
      ZCMXF  = CFMMVD('ZCMXF')
      ZEXCL  = CFMMVD('ZEXCL')
      ZDIRN  = CFMMVD('ZDIRN')
C
      NZOCO  = CFDISI(DEFICO,'NZOCO' )
      IFORM  = CFDISI(DEFICO,'FORMULATION')
      CALL ASSERT(IZONE.GT.0)
      IF (NZOCO.NE.0) THEN
        CALL ASSERT(IZONE.LE.NZOCO)
      ENDIF
C
C ---- INTERROGATION METHCO
C
C --- APPARIEMENT
      IF (QUESTI(1:11).EQ.'APPARIEMENT')    THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+1-1)
C --- DIST_POUTRE
      ELSEIF (QUESTI.EQ.'DIST_POUTRE') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        LREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+2-1).EQ.1
C --- DIST_COQUE
      ELSEIF (QUESTI.EQ.'DIST_COQUE') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        LREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+3-1).EQ.1
C --- DIST_MAIT
      ELSEIF (QUESTI.EQ.'DIST_MAIT') THEN
        CALL JEVEUO(JEUFO1,'L',JJFO1 )
        JEUF1 = ZK8(JJFO1+IZONE-1)
        IF (JEUF1.EQ.' ') THEN
          LREP(1) = .FALSE.
        ELSE
          LREP(1) = .TRUE.
        ENDIF
C --- DIST_ESCL
      ELSEIF (QUESTI.EQ.'DIST_ESCL') THEN
        CALL JEVEUO(JEUFO2,'L',JJFO2 )
        JEUF2 = ZK8(JJFO2+IZONE-1)
        IF (JEUF2.EQ.' ') THEN
          LREP(1) = .FALSE.
        ELSE
          LREP(1) = .TRUE.
        ENDIF

C --- NORMALE
      ELSEIF (QUESTI.EQ.'NORMALE') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+4-1)
C --- NORMALE = 'MAIT'
      ELSEIF (QUESTI.EQ.'MAIT') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+4-1).EQ.0) THEN
          LREP(1) = .TRUE.
        ELSE
          LREP(1) = .FALSE.
        ENDIF
C --- NORMALE = 'MAIT_ESCL'
      ELSEIF (QUESTI.EQ.'MAIT_ESCL') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+4-1).EQ.1) THEN
          LREP(1) = .TRUE.
        ELSE
          LREP(1) = .FALSE.
        ENDIF
C --- NORMALE = 'ESCL'
      ELSEIF (QUESTI.EQ.'ESCL') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+4-1).EQ.2) THEN
          LREP(1) = .TRUE.
        ELSE
          LREP(1) = .FALSE.
        ENDIF
C --- VECT_MAIT
      ELSEIF (QUESTI.EQ.'VECT_MAIT') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+5-1)
C
      ELSEIF (QUESTI.EQ.'VECT_MAIT_DIRX') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+5-1).GT.0) THEN
          CALL JEVEUO(DIRNOR,'L',JDIRNO)
          RREP(1) = ZR(JDIRNO+ZDIRN*(IZONE-1))
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'VECT_MAIT_DIRY') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+5-1).GT.0) THEN
          CALL JEVEUO(DIRNOR,'L',JDIRNO)
          RREP(1) = ZR(JDIRNO+ZDIRN*(IZONE-1)+1)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'VECT_MAIT_DIRZ') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+5-1).GT.0) THEN
          CALL JEVEUO(DIRNOR,'L',JDIRNO)
          RREP(1) = ZR(JDIRNO+ZDIRN*(IZONE-1)+2)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C --- VECT_ESCL
      ELSEIF (QUESTI.EQ.'VECT_ESCL') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+6-1)
C
      ELSEIF (QUESTI.EQ.'VECT_ESCL_DIRX') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+6-1).GT.0) THEN
          CALL JEVEUO(DIRNOR,'L',JDIRNO)
          RREP(1) = ZR(JDIRNO+ZDIRN*(IZONE-1)+3)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'VECT_ESCL_DIRY') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+6-1).GT.0) THEN
          CALL JEVEUO(DIRNOR,'L',JDIRNO)
          RREP(1) = ZR(JDIRNO+ZDIRN*(IZONE-1)+4)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'VECT_ESCL_DIRZ') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+6-1).GT.0) THEN
          CALL JEVEUO(DIRNOR,'L',JDIRNO)
          RREP(1) = ZR(JDIRNO+ZDIRN*(IZONE-1)+5)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C --- TYPE_APPA
      ELSEIF (QUESTI.EQ.'TYPE_APPA') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+7-1)
C
      ELSEIF (QUESTI.EQ.'TYPE_APPA_FIXE') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        LREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+7-1).EQ.1
C
      ELSEIF (QUESTI.EQ.'TYPE_APPA_DIRX') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+7-1).EQ.1) THEN
          CALL JEVEUO(DIRAPP,'L',JDIRAP)
          RREP(1) = ZR(JDIRAP+3*(IZONE-1))
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'TYPE_APPA_DIRY') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+7-1).EQ.1) THEN
          CALL JEVEUO(DIRAPP,'L',JDIRAP)
          RREP(1) = ZR(JDIRAP+3*(IZONE-1)+1)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'TYPE_APPA_DIRZ') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)+7-1).EQ.1) THEN
          CALL JEVEUO(DIRAPP,'L',JDIRAP)
          RREP(1) = ZR(JDIRAP+3*(IZONE-1)+2)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C --- NBMAE
      ELSEIF (QUESTI.EQ.'NBMAE') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+8 -1)
C --- NBNOE
      ELSEIF (QUESTI.EQ.'NBNOE') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+9 -1)
C --- NBMAM
      ELSEIF (QUESTI.EQ.'NBMAM') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+10-1)
C --- NBNOM
      ELSEIF (QUESTI.EQ.'NBNOM') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+11-1)
C --- NBMAET
      ELSEIF (QUESTI.EQ.'NBMAEC') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+12-1)
C --- NBNOET
      ELSEIF (QUESTI.EQ.'NBNOEC') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+13-1)
C --- NBMAM
      ELSEIF (QUESTI.EQ.'NBMAMC') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+14-1)
C --- NBNOM
      ELSEIF (QUESTI.EQ.'NBNOMC') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+15-1)
C --- JDECME
      ELSEIF (QUESTI.EQ.'JDECME') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+16-1)
C --- JDECMM
      ELSEIF (QUESTI.EQ.'JDECMM') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+17-1)
C --- JDECNE
      ELSEIF (QUESTI.EQ.'JDECNE') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+18-1)
C --- JDECNM
      ELSEIF (QUESTI.EQ.'JDECNM') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+19-1)
C --- NBPT
      ELSEIF (QUESTI.EQ.'NBPT') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+20-1)
C --- NBPC
      ELSEIF (QUESTI.EQ.'NBPC') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IREP(1) = ZI(JMETH+ZMETH*(IZONE-1)+21-1)
C --- VERIF
      ELSEIF (QUESTI.EQ.'VERIF') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)-1+22).EQ.0) THEN
          LREP(1) = .FALSE.
        ELSEIF (ZI(JMETH+ZMETH*(IZONE-1)-1+22).EQ.1) THEN
          LREP(1) = .TRUE.
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C --- VERIF
      ELSEIF (QUESTI.EQ.'CALCUL') THEN
        CALL JEVEUO(METHCO,'L',JMETH)
        IF (ZI(JMETH+ZMETH*(IZONE-1)-1+22).EQ.0) THEN
          LREP(1) = .TRUE.
        ELSEIF (ZI(JMETH+ZMETH*(IZONE-1)-1+22).EQ.1) THEN
          LREP(1) = .FALSE.
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
C ---- INTERROGATION TOLECO
C
      ELSEIF (QUESTI.EQ.'TOLE_PROJ_EXT') THEN
        IF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+15-1)
        ELSE
          CALL JEVEUO(TOLECO,'L',JTOLE)
          RREP(1) = ZR(JTOLE+ZTOLE*(IZONE-1)+1-1)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'TOLE_APPA') THEN
        CALL JEVEUO(TOLECO,'L',JTOLE)
        RREP(1) = ZR(JTOLE+ZTOLE*(IZONE-1)+2-1)
C
      ELSEIF (QUESTI.EQ.'TOLE_INTERP') THEN
        CALL JEVEUO(TOLECO,'L',JTOLE)
        RREP(1) = ZR(JTOLE+ZTOLE*(IZONE-1)+3-1)
C
C --- INTERROGATION CARACF
C
      ELSEIF (QUESTI.EQ.'USURE') THEN
        CALL JEVEUO(CARACF,'L',JCMCF)
        IF (ZR(JCMCF-1+ZCMCF*(IZONE-1)+13) .EQ. 0.D0) THEN
          LREP(1) = .FALSE.
          IREP(1) = 0
        ELSE
          LREP(1) = .TRUE.
          IREP(1) = 1
        ENDIF
C
      ELSEIF (QUESTI.EQ.'USURE_K') THEN
        CALL JEVEUO(CARACF,'L',JCMCF)
        RREP(1)  = ZR(JCMCF-1+ZCMCF*(IZONE-1)+14)
C
      ELSEIF (QUESTI.EQ.'USURE_H') THEN
        CALL JEVEUO(CARACF,'L',JCMCF)
        RREP(1)  = ZR(JCMCF-1+ZCMCF*(IZONE-1)+15)
C
      ELSEIF (QUESTI.EQ.'EXCLUSION_PIV_NUL') THEN
        IF (IFORM.EQ.2) THEN
          CALL JEVEUO(CARACF,'L',JCMCF)
          RREP(1) = ZR(JCMCF-1+ZCMCF*(IZONE-1)+16)
          IREP(1) = NINT(RREP(1))
          LREP(1) = (IREP(1).EQ.1)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'ALGO_CONT') THEN
       IF(IFORM.EQ.2) THEN
        CALL JEVEUO(CARACF,'L',JCMCF)
        RREP(1) = ZR(JCMCF-1+ZCMCF*(IZONE-1)+3)
        IREP(1) = NINT(RREP(1))
       ELSEIF(IFORM.EQ.3) THEN
         CALL JEVEUO(CARAXF,'L',JCMXF)
         RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+11-1)
         IREP(1) = NINT(RREP(1))
       ELSE
         CALL ASSERT(.FALSE.)
       ENDIF
        

      ELSEIF (QUESTI.EQ.'ALGO_CONT_PENA') THEN
        IF (IFORM.EQ.2) THEN
          CALL JEVEUO(CARACF,'L',JCMCF)
          IF (NINT(ZR(JCMCF-1+ZCMCF*(IZONE-1)+3)).EQ.3) THEN
            LREP(1) = .TRUE.
          ELSE
            LREP(1) = .FALSE.
          ENDIF
        ELSEIF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+11-1)
          IF (NINT(RREP(1)).EQ.2) THEN
            LREP(1) = .TRUE.
          ELSE
            LREP(1) = .FALSE.
          ENDIF
        ENDIF
C
      ELSEIF (QUESTI.EQ.'ALGO_FROT') THEN
       IF(IFORM.EQ.2) THEN
        CALL JEVEUO(CARACF,'L',JCMCF)
        RREP(1) = ZR(JCMCF-1+ZCMCF*(IZONE-1)+5)
        IREP(1) = NINT(RREP(1))
       ELSEIF(IFORM.EQ.3) THEN
        CALL JEVEUO(CARAXF,'L',JCMXF)
        RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+13-1)
        IREP(1) = NINT(RREP(1))        
       ELSE
         CALL ASSERT(.FALSE.)
       ENDIF

      ELSEIF (QUESTI.EQ.'ALGO_FROT_PENA') THEN
        IF (IFORM.EQ.2) THEN
          CALL JEVEUO(CARACF,'L',JCMCF)
          IF (NINT(ZR(JCMCF-1+ZCMCF*(IZONE-1)+5)).EQ.3) THEN
            LREP(1) = .TRUE.
          ELSE
            LREP(1) = .FALSE.
          ENDIF
        ELSEIF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          RREP(1)=ZR(JCMXF+ZCMXF*(IZONE-1)+13-1)
          IF (NINT(RREP(1)).EQ.2) THEN
            LREP(1) = .TRUE.
          ELSE
            LREP(1) = .FALSE.
          ENDIF
        ENDIF
C
C ---- INTERROGATION CARAXF
C
      ELSEIF (QUESTI.EQ.'RELATION') THEN
        IF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+16-1)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'XFEM_ALGO_LAGR') THEN
        IF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          IREP(1) = NINT(ZR(JCMXF+ZCMXF*(IZONE-1)+9-1))
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'CONT_XFEM_CZM') THEN
        IF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+11-1)
          IF (NINT(RREP(1)).EQ.3) THEN
            LREP(1) = .TRUE.
          ELSE
            LREP(1) = .FALSE.
          ENDIF
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
C ---- INTERROGATION MIXTE CARADF/CARACF/CARAXF
C
      ELSEIF (QUESTI.EQ.'GLISSIERE_ZONE') THEN
        LREP(1) = .FALSE.
        IF (IFORM.EQ.1) THEN
          CALL JEVEUO(CARADF,'L',JCMDF )
          LREP(1) = NINT(ZR(JCMDF+ZCMDF*(IZONE-1)+6 -1)).EQ.1
        ELSEIF (IFORM.EQ.2) THEN
          CALL JEVEUO(CARACF,'L',JCMCF)
          LREP(1) = NINT(ZR(JCMCF-1+ZCMCF*(IZONE-1)+9)).EQ.1
        ELSEIF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          LREP(1) = NINT(ZR(JCMXF+ZCMXF*(IZONE-1)+10-1)).EQ.1
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
C ---- INTERROGATION MIXTE CARACF/CARAXF
C
      ELSEIF (QUESTI.EQ.'INTEGRATION') THEN
        IF (IFORM.EQ.2) THEN
          CALL JEVEUO(CARACF,'L',JCMCF)
          IREP(1) = NINT(ZR(JCMCF-1+ZCMCF*(IZONE-1)+1))
        ELSEIF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          IREP(1) = NINT(ZR(JCMXF+ZCMXF*(IZONE-1)+1-1))
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
C
      ELSEIF (QUESTI.EQ.'COEF_COULOMB') THEN
        IF (IFORM.EQ.2) THEN
          CALL JEVEUO(CARACF,'L',JCMCF)
          RREP(1) = ZR(JCMCF-1+ZCMCF*(IZONE-1)+6)
        ELSEIF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+4-1)
        ELSEIF (IFORM.EQ.1) THEN
          CALL JEVEUO(CARADF,'L',JCMDF )
          RREP(1) = ZR(JCMDF+ZCMDF*(IZONE-1)+4-1)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'COEF_AUGM_CONT') THEN
        IF (IFORM.EQ.2) THEN
          CALL JEVEUO(CARACF,'L',JCMCF)
          RREP(1) = ZR(JCMCF+ZCMCF*(IZONE-1)+2-1)
        ELSEIF(IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+2-1)          
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'COEF_AUGM_FROT') THEN
        IF (IFORM.EQ.2) THEN
          CALL JEVEUO(CARACF,'L',JCMCF)
          RREP(1) = ZR(JCMCF+ZCMCF*(IZONE-1)+4-1)
        ELSEIF(IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+3-1)           
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'FROTTEMENT_ZONE') THEN
        IF (IFORM.EQ.2) THEN
          CALL JEVEUO(CARACF,'L',JCMCF)
          RREP(1) = ZR(JCMCF-1+ZCMCF*(IZONE-1)+5)
          IREP(1) = NINT(RREP(1))
          LREP(1) = IREP(1).NE.0
        ELSEIF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          IREP(1) = NINT(ZR(JCMXF+ZCMXF*(IZONE-1)+5-1))
          LREP(1) = (NINT(ZR(JCMXF+ZCMXF*(IZONE-1)+5-1)).EQ.3)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'SEUIL_INIT') THEN
        IF (IFORM.EQ.2) THEN
          CALL JEVEUO(CARACF,'L',JCMCF)
          RREP(1) = ZR(JCMCF-1+ZCMCF*(IZONE-1)+7)
        ELSEIF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+6-1)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
C
      ELSEIF (QUESTI.EQ.'COEF_PENA_CONT') THEN
        IF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+12-1)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'COEF_PENA_FROT') THEN
        IF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          RREP(1) = ZR(JCMXF+ZCMXF*(IZONE-1)+14-1)
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
      ELSEIF (QUESTI.EQ.'CONTACT_INIT') THEN
        IF (IFORM.EQ.2) THEN
          CALL JEVEUO(CARACF,'L',JCMCF)
          IREP(1) = NINT(ZR(JCMCF-1+ZCMCF*(IZONE-1)+8))
        ELSEIF (IFORM.EQ.3) THEN
          CALL JEVEUO(CARAXF,'L',JCMXF)
          IREP(1) = NINT(ZR(JCMXF+ZCMXF*(IZONE-1)+7-1))
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
C
C ---- INTERROGATION CARADF
C
      ELSEIF (QUESTI.EQ.'COEF_MATR_FROT')   THEN
        CALL JEVEUO(CARADF,'L',JCMDF )
        RREP(1) = ZR(JCMDF+ZCMDF*(IZONE-1)+1-1)

      ELSEIF (QUESTI.EQ.'E_N')   THEN
        CALL JEVEUO(CARADF,'L',JCMDF )
        RREP(1) = ZR(JCMDF+ZCMDF*(IZONE-1)+2-1)

      ELSEIF (QUESTI.EQ.'E_T')   THEN
        CALL JEVEUO(CARADF,'L',JCMDF )
        RREP(1) = ZR(JCMDF+ZCMDF*(IZONE-1)+3-1)

      ELSEIF (QUESTI.EQ.'ALARME_JEU')   THEN
        CALL JEVEUO(CARADF,'L',JCMDF )
        RREP(1) = ZR(JCMDF+ZCMDF*(IZONE-1)+5-1)
C
C --- INTERROGATION EXCLFR
C
      ELSEIF (QUESTI.EQ.'EXCL_DIR')   THEN
        CALL JEVEUO(CARACF,'L',JCMCF)
        IREP(1) = NINT(ZR(JCMCF-1+ZCMCF*(IZONE-1)+12))

      ELSEIF (QUESTI.EQ.'EXCL_FROT_DIRX')   THEN
        CALL JEVEUO(EXCLFR,'L',JEXCLF)
        RREP(1) = ZR(JEXCLF-1+ZEXCL*(IZONE-1)+1)
      ELSEIF (QUESTI.EQ.'EXCL_FROT_DIRY')   THEN
        CALL JEVEUO(EXCLFR,'L',JEXCLF)
        RREP(1) = ZR(JEXCLF-1+ZEXCL*(IZONE-1)+2)
      ELSEIF (QUESTI.EQ.'EXCL_FROT_DIRZ')   THEN
        CALL JEVEUO(EXCLFR,'L',JEXCLF)
        RREP(1) = ZR(JEXCLF-1+ZEXCL*(IZONE-1)+3)
C
      ELSE
        WRITE(6,*) '   NUM. ZONE    : <',IZONE  ,'>'
        WRITE(6,*) '   QUESTION     : <',QUESTI ,'>'
        WRITE(6,*) '   REPONSE  - I : <',IREP(1),'>'
        WRITE(6,*) '   REPONSE  - R : <',RREP(1),'>'
        WRITE(6,*) '   REPONSE  - L : <',LREP(1),'>'
        CALL ASSERT(.FALSE.)
      ENDIF
C
      CALL JEDEMA()
      END
