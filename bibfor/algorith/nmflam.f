      SUBROUTINE NMFLAM(MODELE,NUMEDD,CARELE,COMPOR,SOLVEU,
     &                  NUMINS,RESULT,MATE  ,COMREF,LISCHA,
     &                  DEFICO,RESOCO,METHOD,PARMET,FONACT,
     &                  CARCRI,ITERAT,SDDISC,PREMIE,LICCVG,
     &                  OPTFLA,VALMOI,VALPLU,DEPALG,POUGD ,
     &                  MATASS,MAPREC,MEELEM,MEASSE,VEELEM,
     &                  SDDYNA)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 25/03/2008   AUTEUR REZETTE C.REZETTE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C
      IMPLICIT NONE
      INTEGER      NUMINS,ITERAT,LICCVG(*)
      REAL*8       PARMET(*)
      CHARACTER*8  RESULT,OPTFLA
      CHARACTER*19 MEELEM(8)
      CHARACTER*24 RESOCO
      CHARACTER*16 METHOD(*)
      CHARACTER*19 MATASS,MAPREC
      CHARACTER*19 LISCHA,SOLVEU,SDDISC,SDDYNA
      CHARACTER*24 MODELE,NUMEDD,CARELE,COMPOR
      CHARACTER*24 VALMOI(8),VALPLU(8),DEPALG(8)
      CHARACTER*19 VEELEM(30)
      CHARACTER*24 DEFICO,MATE
      CHARACTER*24 CARCRI,POUGD,COMREF
      LOGICAL      PREMIE,FONACT(*)
      CHARACTER*19 MEASSE(8)
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C CALCUL DE FLAMBEMENT NON LINEAIRE
C      
C ----------------------------------------------------------------------
C      
C
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER      IDES,NBV,NFREQ,NFREQC,NUMARC
      INTEGER      I,IRET,ISLVK,JINFO,IM,LJEVEU,IBID
      INTEGER      INIT,DEFO
      REAL*8       BANDE(2),INSTAM,INSTAP,R8BID,OMEGA2
      REAL*8       FREQM,FREQV,FREQA,FREQR,R8MAEM
      CHARACTER*4  MOD45
      CHARACTER*8  MODES
      CHARACTER*8  SYME,MRIG
      CHARACTER*16 K16BID,OPTION,SAUVMT,SAUVDY,VARACC
      CHARACTER*19 MATGEO,MODE,VECFLA,MEGEOM,MEMASS
      CHARACTER*24 TSCH
      INTEGER      JTSCH     
      CHARACTER*24 K24BID,K24BLA,DEPALT(8)
      CHARACTER*24 DDEPLA,DEPOLD,DEPDE0,DEPDEL,DEPPRE(2)  
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      TSCH   = SDDYNA(1:15)//'.TYPE_SCH'
      CALL JEVEUO(TSCH,'E',JTSCH)
      CALL JEVEUO(SOLVEU(1:19)//'.SLVK','E',ISLVK)
      MEGEOM = MEELEM(7)
      MEMASS = MEELEM(3)
      INSTAM = 0.D0
      INSTAP = 0.D0
      K24BLA = ' ' 
      MODES  = '&&NM45BI'    
      MODE   = '&&NMFLAM.MODEFLAMB'
      VECFLA = '&&NMOP45.VECTFLAMB'
C
      NFREQ = 3
      BANDE(1) = 1.D-5
      BANDE(2) = 1.D5
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      CALL DESAGG(DEPALG,DDEPLA,DEPDEL,DEPOLD,DEPPRE(1),
     &            DEPPRE(2),K24BID,K24BID,K24BID) 
C
C --- INCREMENT DE DEPLACEMENT NUL EN PREDICTION
C  
      DEPDE0 = '&&CNPART.ZERO'        
      CALL AGGLOM(DDEPLA,DEPDE0,DEPOLD,DEPPRE(1),
     &            DEPPRE(2),K24BLA,K24BLA,K24BLA, 5, DEPALT) 
C  
C --- RECUPERATION DES OPTIONS
C         
      IF ( OPTFLA(1:7) .EQ. 'VIBRDYN' ) THEN
        CALL GETVIS('MODE_VIBR','NB_FREQ'  ,1,1,1,NFREQ ,IRET)
        CALL GETVID('MODE_VIBR','MATR_RIGI',1,1,1,MRIG  ,IRET)
        MOD45    = 'VIBR'
        IF ( MRIG(1:4) .EQ. 'ELAS' ) THEN
          SAUVMT    = METHOD(5)
          METHOD(5) = 'ELASTIQUE'
        ELSE IF ( MRIG(1:4) .EQ. 'TANG' ) THEN
          SAUVMT    = METHOD(5)
          METHOD(5) = 'TANGENTE'
        ELSE IF ( MRIG(1:4) .EQ. 'SECA' ) THEN
          SAUVMT    = METHOD(5)
          METHOD(5) = 'SECANTE'
        ELSE
          CALL ASSERT(.FALSE.)  
        ENDIF
        OPTION = 'PLUS_PETITE'
        CALL GETVR8('MODE_VIBR','BANDE',1,1,2,BANDE ,IRET)
        IF ( IRET.NE.0 ) OPTION = 'BANDE'
        R8BID = OMEGA2(BANDE(1))
        BANDE(1) = R8BID
        R8BID = OMEGA2(BANDE(2))
        BANDE(2) = R8BID        
      ELSE
        CALL GETVIS('CRIT_FLAMB','NB_FREQ'  ,1,1,1,NFREQ ,IRET)
        CALL GETVR8('CRIT_FLAMB','CHAR_CRIT',1,1,2,BANDE ,IRET)
        MOD45 = 'FLAM'
        MRIG  = '    '
      ENDIF
C
C --- ON FORCE L'ASSEMBLAGE DE LA MATRICE TANGENTE EN SYMETRIQUE
C --- A CAUSE DE SORENSEN
C
      SYME   = ZK24(ISLVK+5-1)(1:8)
      ZK24(ISLVK+5-1)='OUI'
C
C --- CALCUL DE LA MATRICE TANGENTE ASSEMBLEE 
C
      IF ( OPTFLA(1:7) .EQ. 'VIBRDYN') THEN
        SAUVDY    = ZK16(JTSCH+1-1)
C  ANCIENNEMENT :
C        ZK16(JTSCH+1-1) = 'STATIQUE'
C  ON MODIFIE POUR PASSER PAR SOUS-SRUCTURATION
        ZK16(JTSCH+1-1) = 'DYNAMIQUE'
      ENDIF  
C      
      CALL NMMATR('FLAMBEMENT',
     &            MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &            COMPOR,LISCHA,RESOCO,METHOD,SOLVEU,
     &            PARMET,CARCRI,SDDISC,NUMINS,ITERAT,
     &            VALPLU,POUGD ,VALPLU,MATASS,MAPREC,  
     &            K16BID,DEFICO,DEPALT,PREMIE,FONACT,
     &            MEELEM,MEASSE,VEELEM,LICCVG(5),SDDYNA)
C
      IF ( OPTFLA(1:7) .EQ. 'VIBRDYN') THEN
        ZK16(JTSCH+1-1) = SAUVDY
      ENDIF
C
      IF ( (MRIG(1:4) .EQ. 'ELAS') .OR. (MRIG(1:4) .EQ. 'TANG')
     &  .OR. (MRIG(1:4) .EQ. 'SECA')  ) THEN
        METHOD(5) = SAUVMT
      ENDIF
C 
C --- ON RETABLIT LA SYMETRIE ORIGINELLE
C
      ZK24(ISLVK+5-1)=SYME(1:3)

C         SI ON EST EN PETITS DEPLACEMENTS, DEFO=0
C          ON CALCULER LES VALEURS PROPRES DE KT+LAMBDA.KG
C         SINON ON CALCULE LES VPDE KT+LAMBDA.ID

      CALL JEVEUO(COMPOR(1:19)//'.VALE','L',INIT)
      CALL JEVEUO(COMPOR(1:19)//'.DESC','L',IDES)
      DEFO = 0
      NBV = ZI(IDES-1+3)
      DO 10 I = 1,NBV
        IF (ZK16(INIT+2+20*(I-1)).EQ.'GREEN'
     & .OR. ZK16(INIT+2+20*(I-1)).EQ.'GREEN_GR' .OR.
     &      ZK16(INIT+2+20*(I-1)).EQ.'REAC_GEOM' .OR.
     &      ZK16(INIT+2+20*(I-1)).EQ.'SIMO_MIEHE') THEN
          DEFO = 1
        END IF
   10 CONTINUE
C
C --- CALCUL DE LA RIGIDITE GEOMETRIQUE DANS LE CAS HPP
C
      IF (MOD45 .NE. 'VIBR') THEN
        IF (DEFO.EQ.0) THEN
          CALL NMCALM(MODELE,LISCHA,MATE  ,CARELE,COMPOR,
     &                INSTAM,INSTAP,CARCRI,VALMOI,VALPLU,
     &                DEPALG,'MERIBI',' ' ,'V'   ,.FALSE.,
     &                MEELEM)

          MATGEO = '&&NMFLAM.RIGIGEOM'
          CALL ASMATR(1,MEGEOM,' ',NUMEDD,SOLVEU,' ','ZERO','V',
     &                1,MATGEO)
          CALL DETRSD('MATR_ELEM',MEGEOM)
          OPTION = 'BANDE'
        ELSE
          MATGEO = MATASS
          OPTION = 'PLUS_PETITE'
        ENDIF
      ELSE
        MATGEO = '&&NMFLAM.MASSE'
        CALL ASMAMA(MEMASS,' ',NUMEDD,SOLVEU,LISCHA,
     &              MATGEO)
      ENDIF
C
C --- CALCUL DES MODES PROPRES
C    
C  ON DIFFERENCIE NFREQ (DONNEE UTILISATEUR) DE NFREQC
C  QUI EST LE NB DE FREQ TROUVEES PAR L'ALGO DANS NMOP45
      NFREQC = NFREQ
      CALL NMOP45(MATASS,MATGEO,DEFO  ,OPTION,RESULT,
     &            NFREQC ,BANDE ,MOD45 ,MODES )
      IF (NFREQC.EQ.0) THEN
        GOTO 999
      ENDIF
C
C --- ARCHIVAGE
C
      CALL JEVEUO(SDDISC(1:19)// '.DIIR','L',JINFO)
      NUMARC = NINT(ZR(JINFO))-1
      IF ( MOD45 .EQ. 'VIBR' ) THEN
        VARACC = 'FREQ    '
      ELSEIF ( MOD45 .EQ. 'FLAM' ) THEN  
        VARACC = 'CHAR_CRIT'
      ELSE
        CALL ASSERT(.FALSE.)  
      ENDIF
      FREQM = R8MAEM()
      IM = 0
      DO 60 I = 1,NFREQC
        CALL RSADPA(MODES,'L',1,VARACC,I,0,LJEVEU,K16BID)
        FREQV = ZR(LJEVEU)
        FREQA = ABS(FREQV)
        IF (FREQA.LT.FREQM) THEN
          IM    = I
          FREQM = FREQA
          FREQR = FREQV
        END IF
   60 CONTINUE
      CALL RSADPA(RESULT,'E',1,VARACC,NUMARC,0,LJEVEU,K16BID)
      ZR(LJEVEU) = FREQR
C
C --- AFFICHAGE MODE
C
      CALL NMIMPR('IMPR','IMPR_MODE',MOD45,ZR(LJEVEU),IM)
C
      CALL RSEXCH(MODES,'DEPL',IM    ,MODE,IBID)
      IF ( MOD45 .EQ. 'VIBR' ) THEN
        CALL RSEXCH(RESULT,'MODE_MECA',NUMARC,VECFLA,IBID)
        IF (IBID.LE.100) THEN
          CALL COPISD('CHAMP_GD','G',MODE,VECFLA)
          CALL RSNOCH(RESULT,'MODE_MECA',NUMARC,' ')
        END IF
      ELSEIF ( MOD45 .EQ. 'FLAM' ) THEN 
        CALL RSEXCH(RESULT,'MODE_FLAMB',NUMARC,VECFLA,IBID)
        IF (IBID.LE.100) THEN
          CALL COPISD('CHAMP_GD','G',MODE,VECFLA)
          CALL RSNOCH(RESULT,'MODE_FLAMB',NUMARC,' ')
        END IF
      ELSE
        CALL ASSERT(.FALSE.)  
      ENDIF
C
C --- AFFICHAGE ARCHIVAGE
C
      CALL NMIMPR('IMPR','ARCH_MODE',MOD45,R8BID,NUMARC)
C
  999 CONTINUE      
C
      CALL JEDETC('G',MODES,1)           
     
      CALL JEDEMA()
      END
