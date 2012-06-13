      SUBROUTINE NMIMIN(SDIMPR,SDDISC,SDDYNA,NUMINS)
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
      CHARACTER*24 SDIMPR
      CHARACTER*19 SDDYNA,SDDISC
      INTEGER      NUMINS
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (UTILITAIRE)
C
C INITIALISATION DES IMPRESSIONS
C
C ----------------------------------------------------------------------
C
C
C IN  SDIMPR : SD AFFICHAGE
C IN  SDDYNA : SD DYNAMIQUE
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  NUMINS : NUMERO INSTANT COURANT
C
C
C
C
      INTEGER      JIMPTY,JIMPIN
      CHARACTER*24 IMPTYP,IMPINF
      INTEGER      JIMPRR,JIMPRK,JIMPRI
      CHARACTER*24 IMPRER,IMPREK,IMPREI
      INTEGER      ICOL,NBCOL,FORCOL
      INTEGER      VALI,IBID
      REAL*8       VALR,R8VIDE,INSTAN,DIINST,R8BID
      INTEGER      LENIVO,DININS
      CHARACTER*16 VALK,METLIS
      LOGICAL      NDYNLO,LEXPL
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      INSTAN = DIINST(SDDISC,NUMINS)
      LENIVO = DININS(SDDISC,NUMINS)
      LEXPL  = NDYNLO(SDDYNA,'EXPLICITE')
C
C --- METHODE DE GESTION DE LA LISTE D'INSTANTS
C
      CALL UTDIDT('L'   ,SDDISC,'LIST',IBID  ,'METHODE' ,
     &            R8BID ,IBID  ,METLIS)
C
C --- IMPRESSION TITRE TABLEAU DE CONVERGENCE
C
      IF (LEXPL) THEN
        CALL NMIMPR(SDIMPR,'TITR','EXPLICITE',' ',INSTAN,0)
      ELSE
        IF (METLIS.EQ.'MANUEL') THEN
          LENIVO = DININS(SDDISC,NUMINS)
        ELSEIF (METLIS.EQ.'AUTO') THEN
          LENIVO = 0
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
        CALL NMIMPR(SDIMPR,'TITR','IMPLICITE',' ',INSTAN,LENIVO)
      ENDIF
C
C --- ACCES SD
C
      IMPINF = SDIMPR(1:14)//'.INFO'
      IMPTYP = SDIMPR(1:14)//'.DEFI.TYP'
      IMPRER = SDIMPR(1:14)//'.DEFI.RER'
      IMPREI = SDIMPR(1:14)//'.DEFI.REI'
      IMPREK = SDIMPR(1:14)//'.DEFI.REK'
      CALL JEVEUO(IMPINF,'L',JIMPIN)
      CALL JEVEUO(IMPTYP,'L',JIMPTY)
      CALL JEVEUO(IMPRER,'E',JIMPRR)
      CALL JEVEUO(IMPREI,'E',JIMPRI)
      CALL JEVEUO(IMPREK,'E',JIMPRK)
C
C --- INITIALISATIONS
C
      NBCOL  = ZI(JIMPIN-1+1)
      VALI   = -1
      VALR   = R8VIDE()
      VALK   = ' '
C
C --- TABLEAU DE CONVERGENCE
C
      DO 10 ICOL = 1,NBCOL
        FORCOL    = ZI(JIMPTY-1+ICOL)
        IF (FORCOL.EQ.1) THEN
          ZI(JIMPRI-1+ICOL)   = VALI
        ELSE IF (FORCOL.EQ.2) THEN
          ZR(JIMPRR-1+ICOL)   = VALR
        ELSE IF (FORCOL.EQ.3) THEN
          ZK16(JIMPRK-1+ICOL) = VALK
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
  10  CONTINUE
C
C --- ECRITURE INSTANT
C
      CALL IMPSDR(SDIMPR,'INCR_INST',' ',INSTAN,IBID  )
C
      CALL JEDEMA()
      END
