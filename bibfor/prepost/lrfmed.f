      SUBROUTINE LRFMED(RESU,I,MFICH,NOMGD,TYPCHA,OPTION,PARAM,NOCHMD,
     &                  ACCES,NBORDR,NNU,NIS,NTO,JNUME,JLIST,NOMA,
     &                  NBCMPV,NCMPVA,
     &                  NCMPVM,PROLZ,IINST,CRIT,EPSI,LINOCH,ACCE)
      IMPLICIT  NONE
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 12/11/2012   AUTEUR SELLENET N.SELLENET 
C RESPONSABLE SELLENET N.SELLENET
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
C TOLE CRP_21
C
C     BUT:
C       LECTURE DES RESULTATS PRESENTS DANS LES FICHIERS MED
C       ET STOCKAGE DANS LA SD RESULTAT
C
C
C     ARGUMENTS:
C     ----------
C
C      ENTREE :
C-------------
C IN   RESU     : NOM DE LA SD_RESULTAT
C
C      SORTIE :
C-------------
C OUT  PRCHNO   : PROFIL DU CHAMNO
C
C ......................................................................
C
C

C
C
      INCLUDE 'jeveux.h'
      CHARACTER*6 NOMPRO
      PARAMETER (NOMPRO='LRFMED')
      INTEGER NTYMAX
      INTEGER VALI(2)
      PARAMETER (NTYMAX=66)
      INTEGER NNOMAX
      PARAMETER (NNOMAX=27)
      INTEGER NDIM,TYPGEO(NTYMAX),LETYPE
      INTEGER NBTYP,NNOTYP(NTYMAX)
      INTEGER RENUMD(NTYMAX),NUANOM(NTYMAX,NNOMAX)
      INTEGER MODNUM(NTYMAX),NUMNOA(NTYMAX,NNOMAX)
      INTEGER NTO,NNU,JLIST,NBORDR
      INTEGER JNUME,NIS,NPAS,FID,MAJOR,MINOR,REL
      INTEGER IRET,IFIMED
      INTEGER I,IER
      INTEGER IPAS,IAUX2
      INTEGER INDIIS
      INTEGER IBID,J
      INTEGER MFICH,JINST,ITPS
      INTEGER IFM,NIVINF,JREFE,JNUOM
      INTEGER NBMA,JNBPGM,JNBPMM,ORDINS
      REAL*8 EPSI,R8B
      CHARACTER*3 PROLZ
      CHARACTER*4 ACCE
      CHARACTER*8 RESU,NOMA,TYPCHA
      CHARACTER*8 CRIT
      CHARACTER*8 K8BID
      CHARACTER*8 NOMTYP(NTYMAX),PARAM
      CHARACTER*10 ACCES
      CHARACTER*16 LINOCH(100)
      CHARACTER*19 NOMCH
      CHARACTER*19 PREFIX,CHANOM,PCHN1
      CHARACTER*24 VALK(2)
      CHARACTER*24 NOMPRN
      CHARACTER*24 OPTION
      CHARACTER*64  NOCHMD
      CHARACTER*64  NOMAMD
      CHARACTER*200 NOFIMD
      CHARACTER*255 KFIC
      INTEGER TYPENT,TYPGOM
      INTEGER EDLECT
      PARAMETER (EDLECT=0)
      INTEGER EDNOEU
      PARAMETER (EDNOEU=3)
      INTEGER EDMAIL
      PARAMETER (EDMAIL=0)
      INTEGER EDNOMA
      PARAMETER (EDNOMA=4)
      INTEGER EDNONO
      PARAMETER (EDNONO=-1)
      INTEGER TYPNOE
      PARAMETER (TYPNOE=0)
      CHARACTER*1 SAUX01
      CHARACTER*8 SAUX08

      CHARACTER*8 NOMGD
      INTEGER NUMPT,NUMORD,INUM
      INTEGER NBCMPV,IAUX,NPAS0,ITPS0

      INTEGER IINST
      REAL*8 INST

      CHARACTER*24 NCMPVA,NCMPVM

      CHARACTER*64 K64B

      LOGICAL EXISTM,IDENSD,LOGAUX
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()

      NOMPRN = RESU//'.PRFCN00000.PRNO'

      CALL INFMAJ
      CALL INFNIV(IFM,NIVINF)

C     NOM DU FICHIER MED
      CALL ULISOG(MFICH, KFIC, SAUX01)
      IF ( KFIC(1:1).EQ.' ' ) THEN
        CALL CODENT ( MFICH, 'G', SAUX08 )
        NOFIMD = 'fort.'//SAUX08
      ELSE
        NOFIMD = KFIC(1:200)
      ENDIF
C
      CALL MFOUVR(FID,NOFIMD,EDLECT,IRET)
      CALL MFVELI(FID,MAJOR,MINOR,REL,IRET)
      IF ( MAJOR.LT.3 ) THEN
        NOCHMD(33:64) = '                                '
      ENDIF
      CALL MFFERM(FID,IRET)
C
      IF (NIVINF.GT.1) THEN
        WRITE(IFM,*) '<',NOMPRO,'> NOM DU FICHIER MED : ',NOFIMD
      ENDIF
C               12   345678   90123456789
      PREFIX = '&&'//NOMPRO//'.MED'
      CALL JEDETR(PREFIX//'.NUME')
      CALL JEDETR(PREFIX//'.INST')
C      CALL JEDETC('V',PREFIX,1)

C         RECUPERATION DU NOMBRE DE PAS DE TEMPS DANS LE CHAMP
C         ----------------------------------------------------
      IFIMED = 0
      IF (TYPCHA(1:2).EQ.'NO') THEN
        TYPENT = EDNOEU
        TYPGOM = TYPNOE
        CALL MDCHIN(NOFIMD,IFIMED,NOCHMD,TYPENT,TYPGOM,
     &              PREFIX,NPAS,IRET)
        IF (NPAS.EQ.0) THEN
          CALL U2MESK('A','MED_95',1,NOCHMD)
          GO TO 240
        END IF
        CALL JEVEUO(PREFIX//'.INST','L',IPAS)
        CALL JEVEUO(PREFIX//'.NUME','L',INUM)

      ELSE IF (TYPCHA(1:2).EQ.'EL') THEN
        IFIMED = 0
        CALL MDEXPM(NOFIMD,IFIMED,NOMAMD,EXISTM,NDIM,IRET)
        CALL LRMTYP(NBTYP,NOMTYP,NNOTYP,TYPGEO,RENUMD,
     &              MODNUM, NUANOM, NUMNOA )
        IF(TYPCHA(1:4).EQ.'ELNO')THEN
          TYPENT = EDNOMA
        ELSE
          TYPENT = EDMAIL
        ENDIF

        DO 230,LETYPE = 1,NBTYP
          IAUX = RENUMD(LETYPE)
          TYPGOM = TYPGEO(IAUX)
          IFIMED = 0
          CALL MDCHIN(NOFIMD,IFIMED,NOCHMD,TYPENT,TYPGOM,
     &                PREFIX,NPAS,IRET)
          IF (NPAS.NE.0) THEN
            CALL JEVEUO(PREFIX//'.INST','L',IPAS)
            CALL JEVEUO(PREFIX//'.NUME','L',INUM)
            GO TO 240
          END IF
230     CONTINUE

C         CAS PARTICULIER: LECTURE DU FICHIER MED DONT L'ENTITE
C         DES CHAMPS ELNO EST ENCORE 'MED_MAILLE'
        IF(TYPCHA(1:4).EQ.'ELNO')THEN
          TYPENT = EDMAIL
          CALL U2MESK('A','MED_53',1,NOCHMD)
          DO 231,LETYPE = 1,NBTYP
            IAUX = RENUMD(LETYPE)
            TYPGOM = TYPGEO(IAUX)
            IFIMED = 0
            CALL MDCHIN(NOFIMD,IFIMED,NOCHMD,TYPENT,TYPGOM,
     &                  PREFIX,NPAS,IRET)
            IF (NPAS.NE.0) THEN
              CALL JEVEUO(PREFIX//'.INST','L',IPAS)
              CALL JEVEUO(PREFIX//'.NUME','L',INUM)
              GO TO 240
            END IF
231       CONTINUE
        END IF

      END IF
240   CONTINUE
C
      IF(ACCES.NE.'TOUT_ORDRE')THEN
         NPAS0=NBORDR
      ELSE
         NPAS0=NPAS
      ENDIF

C         DETERMINATION DES NUMEROS D'ORDRE MED : ZI(JNUOM)
      IF(NNU.NE.0)THEN
        CALL WKVECT('&&OP0150_NUMORD_MED','V V I',NPAS,JNUOM)
        DO 242 J=1,NPAS
          IF(ZI(INUM+2*J-1).NE.EDNONO) THEN
            ZI(JNUOM+J-1)=ZI(INUM+2*J-1)
          ELSEIF(ZI(INUM+2*(J-1)).NE.EDNONO) THEN
            ZI(JNUOM+J-1)=ZI(INUM+2*(J-1))
          ENDIF
242     CONTINUE
      ENDIF

      CALL DISMOI('F','NB_MA_MAILLA',NOMA,'MAILLAGE',NBMA,K8BID,IRET)
      CALL WKVECT('&&OP0150_NBPG_MAILLE','V V I',NBMA,JNBPGM)
      CALL WKVECT('&&OP0150_NBPG_MED','V V I',NBMA,JNBPMM)

C         BOUCLE SUR LES PAS DE TEMPS
C         ---------------------------
C     CET ENTIER SERT A AVOIR LA CERTITUDE QUE LE .ORDR PRODUIT
C     EN SORTIE DE LIRE_RESU SERA STRICTEMENT CROISSANT
      ORDINS = 1
      DO 250 ITPS = 1,NPAS0
        CHANOM = '&&LRFMED.TEMPOR'
        K64B = ' '
C
        IF(NNU.NE.0)THEN
          NUMORD = ZI(JNUME+ITPS-1)
          ITPS0=INDIIS(ZI(JNUOM),NUMORD,1,NPAS)
          IF(ITPS0.EQ.0)THEN
            CALL U2MESG('A','MED_87',1,RESU,1,NUMORD,0,R8B)
            GOTO 250
          ENDIF
          NUMPT=ZI(INUM+2*ITPS0-2)
        ELSEIF(NTO.NE.0)THEN
          NUMORD = ZI(INUM+2*ITPS-1)
          NUMPT  = ZI(INUM+2*ITPS-2)
        ELSEIF(NIS.NE.0)THEN
          INST = ZR(JLIST+ITPS-1)
          LOGAUX = .FALSE.
          DO 222 , IAUX2 = 1 , NPAS0
            IF( CRIT(1:4).EQ.'RELA' ) THEN
              IF(ABS(ZR(IPAS-1+IAUX2)-INST).LE.ABS(EPSI*INST)) THEN
                LOGAUX = .TRUE.
              ENDIF
            ELSE IF( CRIT(1:4).EQ.'ABSO' ) THEN
              IF(ABS(ZR(IPAS-1+IAUX2)-INST).LE.ABS(EPSI)) THEN
                LOGAUX = .TRUE.
              ENDIF
            ENDIF
            IF ( LOGAUX ) THEN
              NUMPT = ZI(INUM+2*IAUX2-2)
              NUMORD = ZI(INUM+2*IAUX2-1)
              GOTO 2221
            ENDIF
 222      CONTINUE
 2221     CONTINUE
        ENDIF

        CALL LRCHME(CHANOM,NOCHMD,K64B,NOMA,TYPCHA,NOMGD,TYPENT,
     &              NBCMPV,NCMPVA,NCMPVM,PROLZ,
     &              IINST,NUMPT,NUMORD,INST,CRIT,EPSI,
     &              MFICH,OPTION,PARAM,ZI(JNBPGM),ZI(JNBPMM),
     &              IRET)

C         POUR LES CHAM_NO : POUR ECONOMISER L'ESPACE,
C         ON ESSAYE DE PARTAGER LE PROF_CHNO DU CHAMP CREE AVEC
C         LE PROF_CHNO PRECEDENT :
        IF (TYPCHA.EQ.'NOEU') THEN
          CALL DISMOI('F','PROF_CHNO',CHANOM,'CHAM_NO',IBID,
     &                PCHN1,IER)
          IF (.NOT.IDENSD('PROF_CHNO',NOMPRN(1:19),PCHN1)) THEN
            CALL GNOMSD( ' ',NOMPRN,15,19 )
            CALL COPISD( 'PROF_CHNO', 'G', PCHN1, NOMPRN )
          END IF
          CALL JEVEUO( CHANOM//'.REFE', 'E', JREFE )
          ZK24(JREFE+1) = NOMPRN(1:19)
          CALL DETRSD( 'PROF_CHNO', PCHN1)
        END IF
        IF (NUMORD.EQ.EDNONO) THEN
          NUMORD = NUMPT
        END IF
        IF(NIS.NE.0)THEN
          NUMORD = ORDINS
          ORDINS = ORDINS + 1
        ENDIF

        CALL RSEXCH(' ',RESU,LINOCH(I),NUMORD,NOMCH,IRET)
        IF (IRET.EQ.100) THEN
        ELSE IF (IRET.EQ.110) THEN
          CALL RSAGSD(RESU,0)
          CALL RSEXCH(' ',RESU,LINOCH(I),NUMORD,NOMCH,IRET)
        ELSE
          VALK (1) = RESU
          VALK (2) = CHANOM
          VALI (1) = ITPS
          VALI (2) = IRET
          CALL U2MESG('F','UTILITAI8_27',2,VALK,2,VALI,0,0.D0)
        END IF
        CALL COPISD('CHAMP_GD','G',CHANOM,NOMCH)
        CALL RSNOCH(RESU,LINOCH(I),NUMORD)
        CALL RSADPA(RESU,'E',1,ACCE,NUMORD,0,JINST,K8BID)

        IF(NIS.NE.0)THEN
          ZR(JINST) = INST
        ELSEIF(NNU.NE.0)THEN
          ZR(JINST) = ZR(IPAS-1+ITPS0)
        ELSEIF(NTO.NE.0)THEN
          ZR(JINST) = ZR(IPAS-1+ITPS)
        ENDIF
        CALL DETRSD('CHAMP_GD',CHANOM)
250   CONTINUE
      CALL JEDETR('&&OP0150_NBPG_MAILLE')
      CALL JEDETR('&&OP0150_NBPG_MED')
      CALL JEDETR(NCMPVA)
      CALL JEDETR(NCMPVM)
      CALL JEDETR('&&OP0150_NUMORD_MED')
C
      CALL JEDEMA()
C
      END
