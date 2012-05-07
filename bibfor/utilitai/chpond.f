      SUBROUTINE CHPOND(TYCH,DEJAIN,CHIN,CESOUT,CESPOI,MODELE)

      IMPLICIT NONE

      CHARACTER*8 MODELE
      CHARACTER*19 CHIN,CESOUT,CESPOI
      CHARACTER*4 TYCH,DEJAIN
C    -------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 07/05/2012   AUTEUR SELLENET N.SELLENET 
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
C     OPERATEUR   POST_ELEM
C     TRAITEMENT DU MOT CLE-FACTEUR "INTEGRALE"
C     ROUTINE D'APPEL : PEECAL
C
C     BUT : CALCULE UN CHAMP ELXX PONDERE DU POIDS DES "POINTS"
C          (POIDS*JACOBIEN)
C
C     IN  CHIN      : CHAMP A PONDERER   (CHAM_ELEM   /ELXX)
C     IN  TYCH      : TYPE DU CHAMP (ELNO/ELGA/ELEM)
C     IN  MODELE    : NOM DU MODELE
C     IN  DEJAIN    : POUR LES CHAMPS ELEM : DEJA_INTEGRE=OUI/NON
C     OUT CESOUT    : CHIN + PONDERATION (CHAM_ELEM_S /ELXX)
C     IN/OUT CESPOI : PONDERATION        (CHAM_ELEM_S /ELXX)
C                     + OBJET .PDSM (POIDS DES MAILLES)
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      INTEGER IBID,IRET,NBCHIN,NBMA,NBPT,NBSP,NBCMP,JOUTV,JOUTL,JOUTD
      INTEGER IAD1,IAD2,IAD3,ISP,IMA,ICMP,IPT,JCHSV,JCHSL,JCHSD,IEXI
      INTEGER JPOIV,JPOID,JPOIL,JPOIC,JCH2,JCH1,IRET1,IRET2,JPDSM
      INTEGER INDMA
      REAL*8 POIDS
      PARAMETER(NBCHIN=2)
      CHARACTER*8 LPAIN(NBCHIN),LPAOUT(1),NOMA,K8B,VALK
      CHARACTER*19 CHINS
      CHARACTER*24 LIGREL,CHGEOM,LCHIN(NBCHIN),LCHOUT(2),VEFCH1,VEFCH2
      LOGICAL EXIGEO,PEECAL

      CALL JEMARQ()

      CALL DISMOI('F','NOM_LIGREL',CHIN,'CHAM_ELEM',IBID,LIGREL,IBID)

      CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,NOMA,IRET)
      CALL DISMOI('F','NB_MA_MAILLA',NOMA,'MAILLAGE',NBMA,K8B,IRET)
      CALL JEEXIN('&&PEECAL.IND.MAILLE',IRET)
      PEECAL=.TRUE.
      IF(IRET.EQ.0)THEN
        PEECAL=.FALSE.
      ELSE
        CALL JEVEUO('&&PEECAL.IND.MAILLE','L',INDMA)
      ENDIF


C --- CALCUL DU CHAMP CESPOI
C    (UNIQUEMENT AU PREMIER NUMERO D'ORDRE RENCONTRE)

      CALL JEEXIN(CESPOI//'.CESV',IRET)

      IF(IRET.EQ.0)THEN

        CALL MEGEOM(MODELE,' ',EXIGEO,CHGEOM)
        LCHIN(1)=CHGEOM(1:19)
        LPAIN(1)='PGEOMER'
        LCHOUT(1)='&&PEECAL.PGCOOR'
        LPAOUT(1)='PCOORPG'

        CALL CALCUL('S','COOR_ELGA',LIGREL,1,LCHIN,LPAIN,1,LCHOUT,
     &               LPAOUT,'V','OUI')

C       --- VERIFICATION SUR LES CHAMPS CESPOI ET CHIN :
C       (MEME FAMILLE DE PG & MEME ELEMENT DE REFERENCE)
        IF (TYCH.EQ.'ELGA') THEN
          VEFCH1='&&PEECAL.FPGCHIN'
          VEFCH2='&&PEECAL.FPGCOOR'
          CALL CELFPG(CHIN,VEFCH1,IRET1)
          CALL ASSERT(IRET1.EQ.0)
          CALL CELFPG(LCHOUT(1),VEFCH2,IRET2)
          CALL ASSERT(IRET2.EQ.0)
          CALL JEVEUO(VEFCH1,'L',JCH1)
          CALL JEVEUO(VEFCH2,'L',JCH2)
          DO 5 IMA=1,NBMA
C           -- IL NE FAUT VERIFIER QUE LES MAILLES AFFECTEES DE CHIN:
            IF (ZK16(JCH1+IMA-1).EQ.' ') GOTO 5
C           -- IL NE FAUT VERIFIER QUE LES MAILLES POSTRAITEES:
            IF(.NOT.PEECAL .OR. (PEECAL .AND. ZI(INDMA+IMA-1).EQ.1))THEN
C           -- SI LE CHAMP COOR_ELGA N'EST PAS CALCULE ON S'ARRETE:
              IF (ZK16(JCH2+IMA-1).EQ.' ') THEN
                VALK=ZK16(JCH1+IMA-1)(1:8)
                CALL U2MESG('F','UTILITAI8_63',1,VALK,1,IMA,0,0.D0)
              ENDIF
              IF (ZK16(JCH1+IMA-1).NE.ZK16(JCH2+IMA-1)) THEN
                CALL U2MESK('F','CALCULEL2_4',1,ZK16(JCH1+IMA-1))
              ENDIF
            ENDIF
5        CONTINUE
          CALL JEDETR(VEFCH1)
          CALL JEDETR(VEFCH2)
        ENDIF

        CALL CELCES(LCHOUT(1), 'V', CESPOI )
        CALL CESRED(CESPOI,0,IBID,1,'W','V',CESPOI)

      ENDIF

C --- CREATION ET RECUPERATION DES POINTEURS

      CALL JEVEUO(CESPOI//'.CESV','L',JPOIV)
      CALL JEVEUO(CESPOI//'.CESL','L',JPOIL)
      CALL JEVEUO(CESPOI//'.CESD','L',JPOID)
      CALL JEVEUO(CESPOI//'.CESC','L',JPOIC)

      CHINS='&&CHPOND.CHINS'
      CALL CELCES ( CHIN, 'V', CHINS )
      CALL JEVEUO(CHINS//'.CESV','L',JCHSV)
      CALL JEVEUO(CHINS//'.CESL','L',JCHSL)
      CALL JEVEUO(CHINS//'.CESD','L',JCHSD)

C --- CREATION ET REMPLISSAGE DES CHAMPS OUT

      CALL COPISD('CHAM_ELEM_S','V',CHINS,CESOUT)

      CALL JEVEUO(CESOUT//'.CESV','E',JOUTV)
      CALL JEVEUO(CESOUT//'.CESL','E',JOUTL)
      CALL JEVEUO(CESOUT//'.CESD','E',JOUTD)

      NBMA = ZI(JPOID-1+1)
C     -- CALCUL DU VOLUME DES MAILLES (SI ELEM ET ELNO) :
      IF (TYCH.NE.'ELGA') THEN
        CALL JEEXIN(CESPOI//'.PDSM',IEXI)
        IF (IEXI.EQ.0) THEN
          CALL WKVECT(CESPOI//'.PDSM','V V R',NBMA,JPDSM)
          DO 11 IMA=1,NBMA
            IF(.NOT.PEECAL .OR. (PEECAL .AND. ZI(INDMA+IMA-1).EQ.1))THEN
            NBPT=ZI(JPOID-1+5+4*(IMA-1)+1)
            DO 21 IPT=1,NBPT
              CALL CESEXI('C',JPOID,JPOIL,IMA,IPT,1,1,IAD2)
              CALL ASSERT(IAD2.GT.0)
              ZR(JPDSM-1+IMA)=ZR(JPDSM-1+IMA)+ZR(JPOIV-1+IAD2)
 21         CONTINUE
            ENDIF
 11       CONTINUE
        ELSE
          CALL JEVEUO(CESPOI//'.PDSM','L',JPDSM)
        ENDIF
      ENDIF


C     -- PONDERATION DU CHAMP PAR LES POIDS DES POINTS :
      DO 10 IMA=1,NBMA
        IF(.NOT.PEECAL .OR. (PEECAL .AND. ZI(INDMA+IMA-1).EQ.1))THEN
        NBPT =ZI(JCHSD-1+5+4*(IMA-1)+1)
        NBSP =ZI(JCHSD-1+5+4*(IMA-1)+2)
        NBCMP=ZI(JCHSD-1+5+4*(IMA-1)+3)
        DO 20 IPT=1,NBPT
          IF (TYCH.EQ.'ELGA') THEN
            CALL CESEXI('S',JPOID,JPOIL,IMA,IPT,1,1,IAD2)
            CALL ASSERT(IAD2.GT.0)
            POIDS=ZR(JPOIV-1+IAD2)
          ELSEIF (TYCH.EQ.'ELEM') THEN
            CALL ASSERT(NBPT.EQ.1)
            IF (DEJAIN.EQ.'NON') THEN
               POIDS=ZR(JPDSM-1+IMA)
            ELSE
               POIDS=1.D0
            ENDIF
          ELSEIF (TYCH.EQ.'ELNO') THEN
            CALL ASSERT(NBPT.GT.0)
            POIDS=ZR(JPDSM-1+IMA)/NBPT
          ENDIF

          DO 30 ISP=1,NBSP
            DO 40 ICMP=1,NBCMP
               CALL CESEXI('C',JCHSD,JCHSL,IMA,IPT,ISP,ICMP,IAD1)
               CALL CESEXI('C',JOUTD,JOUTL,IMA,IPT,ISP,ICMP,IAD3)
C              IAD1 ET IDA3 DOIVENT ETRE DU MEME SIGNE SINON
C              CELA SIGNIFIE QUE LES DEUX CHAMPS N'ONT PAS LE
C              MEME PROFIL
               IF ( .NOT.(IAD1.GT.0.AND.IAD3.GT.0) ) THEN
                 CALL ASSERT(.FALSE.)
               ELSE
C                SI IAD1 EST NEGATIF OU NUL ALORS IL N'Y A
C                RIEN A REMPLIR ON PASSE A LA CMP SUIVANTE
                 IF ( IAD1.LE.0 ) GOTO 40
                 ZR(JOUTV-1+IAD3)=ZR(JCHSV-1+IAD1)*POIDS
               ENDIF
 40         CONTINUE
 30       CONTINUE
 20     CONTINUE
        ENDIF
 10   CONTINUE

      CALL JEDEMA()

      END
