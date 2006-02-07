      SUBROUTINE VP2TRD(TYPE,NBVECT,ALPHA,BETA,SIGNES,VECPRO,MXITER,
     &                  NITQR)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 07/02/2006   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*1       TYPE
      INTEGER                NBVECT,MXITER,NITQR
      REAL*8                 ALPHA(*),BETA(*),SIGNES(*),VECPRO(*)
C     ------------------------------------------------------------------
C     RESOLUTION DU SYSTEME TRIDIAGONAL SYMETRIQUE OU NON SYMETRIQUE.
C     ISSU DE LA METHODE DE LANCZOS.
C     ------------------------------------------------------------------
C IN  TYPE   : K1 : TYPE DU PROBLEME
C       'G' -  LA TRIDIAGONALE EST ISSUE D'UN PROBLEME GENERALISE
C       'Q' -  LA TRIDIAGONALE EST ISSUE D'UN PROBLEME QUADRATIQUE
C IN  NBVECT : I : NOMBRE D'EQUATION (==> DE VECTEURS PROPRES)
C VAR ALPHA  : R :
C        EN ENTREE : ALPHA(I) CONTIENT LE I-EME TERME DIAGONAL
C        EN SORTIE : 'G' - CONTIENT LA PULSATION DU PROBLEME INVERSE
C                    'Q' - CONTIENT IM(VAL_PROP_TRI_DIAG)
C VAR BETA   : R  :
C        EN ENTREE : BETA(I) CONTIENT LE TERME SUR-DIAGONAL A(I-1,I)
C                    PAR CONVENTION BETA(1) = 0
C        EN SORTIE : 'G' - CONTIENT L'AMORTISSEMENT DU PROBLEME INVERSE
C                    'Q' - CONTIENT RE(VAL_PROPTRI_DIAG)
C IN  SIGNES
C IN  MXITER : I : NOMBRE D'ITERATION MAXIMUM POUR LA METHODE (QL/QR)
C            : REMARQUE MXITER = 30 EST UN BON CHOIX.
C OUT NITQR : NOMBRE MAXIMAL D'ITERATIONS ATTEINT AVEC LA METHODE QR
C     ------------------------------------------------------------------
C     REMARQUE : 'G' - TRI SUIVANT LES PULSATION CROISSANTES
C                'Q' - PAS DE TRI
C     ------------------------------------------------------------------
C
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
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
C     ------------------------------------------------------------------
      REAL*8      SYMET
      CHARACTER *8 METHOD
C     ------------------------------------------------------------------
C
C     ---  ON DETECTE LES FREQUENCES INFERIEURES AU SHIFT ---
      CALL JEMARQ()
      IF ( TYPE .EQ. 'G' ) THEN
         SYMET = SIGNES(1)
         DO 10 IVEC = 2,NBVECT
            SYMET = MIN( SIGNES(IVEC),SYMET )
   10    CONTINUE
      ELSE
         SYMET = - 1.D0
      ENDIF
C
      IF (SYMET .GT. 0.D0 ) THEN
C
C        --- CAS OU LA TRIDIAGONALE EST SYMETRIQUE ---
         CALL VPQLTS(ALPHA,BETA,NBVECT,VECPRO,NBVECT,MXITER,IER,NITQR)
         DO 15 IVECT = 1, NBVECT
            BETA(IVECT) = 0.0D0
  15     CONTINUE
C
      ELSE
C
C        --- CAS OU LA TRIDIAGONALE N'EST PAS SYMETRIQUE ---
         METHOD = 'TRI_DIAG'
         N2 = 2*NBVECT
         IF (TYPE .EQ. 'G' ) THEN
C
            CALL WKVECT('&&VP2TRD.ZONE.TRAV','V V R',N2,LADW1)
            CALL WKVECT('&&VP2TRD.WK.VPHQRP','V V R',N2,LADWK1)
            CALL WKVECT('&&VP2TRD.Z.VPHQRP ','V V R',N2*N2,LADZ1)
            CALL VP2TRU(METHOD,TYPE,ALPHA,BETA,SIGNES,VECPRO,NBVECT,
     +                  ZR(LADW1),ZR(LADZ1),ZR(LADWK1),MXITER,IER,NITQR)
            CALL JEDETR('&&VP2TRD.ZONE.TRAV' )
            CALL JEDETR('&&VP2TRD.WK.VPHQRP' )
            CALL JEDETR('&&VP2TRD.Z.VPHQRP ' )
         ELSE
           CALL WKVECT('&&VP2TRD.W.VPHQRP ','V V R',N2,LADW2)
           CALL WKVECT('&&VP2TRD.A.VPHQRP ','V V R',NBVECT*NBVECT,LADZ2)
           CALL WKVECT('&&VP2TRD.WK.VPHQRP','V V R',N2,LADWK2)
C
            CALL VP2TRU(METHOD,TYPE,ALPHA,BETA,SIGNES,ZR(LADZ2),NBVECT,
     +                  ZR(LADW2),VECPRO,ZR(LADWK2),MXITER,IER,NITQR)
            CALL JEDETR('&&VP2TRD.W.VPHQRP  ' )
            CALL JEDETR('&&VP2TRD.A.VPHQRP  ' )
            CALL JEDETR('&&VP2TRD.WK.VPHQRP ' )
         ENDIF
      ENDIF
C
      IF (NBVECT.EQ.1) VECPRO(1) = 1.D0
      IF (IER.NE.0) CALL UTMESS('F','VP2TRD','PROBLEME A LA '//
     +                              'RESOLUTION DU SYSTEME REDUIT.')
C
C     --- PASSAGE AUX VALEURS PROPRES DU SYSTEME INITIAL ---
      IF ( TYPE .EQ. 'G' ) THEN
         DO 30 IVECT = 1, NBVECT
            IF ( ALPHA(IVECT) .EQ. 0.0D0 ) THEN
               CALL UTMESS('A','VP2TRD','VALEUR PROPRE INFINIE TROUVEE')
               ALPHA(IVECT) = 1.D+70
            ELSE
               ALPHA(IVECT) = 1.D0 / ALPHA(IVECT)
            ENDIF
30       CONTINUE
C        --- TRI DES ELEMENTS PROPRES PAR ORDRE CROISSANT DES VALEURS
C            ABSOLUES DES VALEURS PROPRES
         CALL VPORDO( 1, 0, NBVECT, ALPHA, VECPRO, NBVECT)
      ELSEIF ( TYPE .EQ. 'Q' ) THEN
C        -- POUR LE PB Q LA RESTORATION DEPEND DE L'APPROCHE (CF:WP2VEC)
      ENDIF
C
      CALL JEDEMA()
      END
