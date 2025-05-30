ATTACH "data/raw/RMPData.sqlite" as db;

-- SubmissionMeta
CREATE TEMPORARY VIEW SubmissionMeta AS
    SELECT
        FacilityID AS SubmissionID,
        EPAFacilityID,
        SUBSTR(ReceiptDate, 1, 10) AS ReceiptDate,
        SUBSTR(CompletionCheckDate, 1, 10) AS ValidationDate,
        SUBSTR(DeRegistrationDate, 1, 10) AS DeregDate,
        SUBSTR(DeRegistrationEffectiveDate, 1, 10) AS DeregEffDate,
        SubmissionType AS SubType,
        RMPSubmissionReasonCode AS SubReasonCode,
        FacilityName AS FacName,
        FacilityLatDecDegs AS FacLat,
        FacilityLongDecDegs AS FacLng,
        FRS_Lat AS FRSLat,
        FRS_Long AS FRSLng,
        FTE AS FacFTE,
        ParentCompanyName AS FacCompany1,
        Company2Name AS FacCompany2,
        OperatorName AS FacOperator,
        FacilityStr1 AS Addr1,
        FacilityStr2 AS Addr2,
        FacilityCity AS City,
        FacilityState AS State,
        FacilityZipCode AS ZipCode,
        FacilityCountyFIPS AS CountyFIPS

    FROM
        tblS1Facilities
    ORDER BY
        ValidationDate DESC,
        ReceiptDate DESC,
        SubmissionID DESC;

-- ** Accident-level **

-- AccidentChemicals
CREATE TEMPORARY VIEW AccidentChemicals AS 
    SELECT
        a.FacilityID AS SubmissionID,
        a.AccidentHistoryID,
        ChemicalName,
        QuantityReleased AS Quantity
    FROM
        tblS6AccidentHistory a
    LEFT JOIN tblS6AccidentChemicals ac
        ON a.AccidentHistoryID = ac.AccidentHistoryID
    LEFT JOIN tlkpChemicals lk
        ON ac.ChemicalID = lk.ChemicalID;
    
-- AccidentChemicalsByAccident
CREATE TEMPORARY VIEW AccidentChemicalsByAccident AS 
    SELECT
        SubmissionID,
        AccidentHistoryID,
        GROUP_CONCAT(
            ChemicalName || ' {' || CAST(Quantity AS INT) || '}',
            ' • '
        ) AS AccidentChemicals
    FROM (
        SELECT * FROM AccidentChemicals
        ORDER BY
            Quantity DESC,
            ChemicalName ASC
    )
    GROUP BY
        SubmissionID,
        AccidentHistoryID;

-- Accidents
CREATE TEMPORARY VIEW AccidentEntries AS
    SELECT
        EPAFacilityID,
        FacilityID AS SubmissionID,
        a.AccidentHistoryID,
        SUBSTR(AccidentDate, 1, 10) AS AccidentDate,
        SUBSTR(AccidentTime, 1, 2) || SUBSTR(AccidentTime, 4, 2) AS AccidentTime,
        ac.AccidentChemicals,
        AccidentReleaseDuration,
        NAICSCode,
        RE_Gas,
        RE_Spill,
        RE_Fire,
        RE_Explosion,
        RE_ReactiveIncident,
        RS_StorageVessel,
        RS_Piping,
        RS_ProcessVessel,
        RS_TransferHose,
        RS_Valve,
        RS_Pump,
        RS_Joint,
        OtherReleaseSource,
        WindSpeed,
        WindSpeedUnitCode,
        WindDirection,
        Temperature,
        StabilityClass,
        Precipitation,
        WeatherUnknown,
        DeathsWorkers,
        DeathsPublicResponders,
        DeathsPublic,
        InjuriesWorkers,
        InjuriesPublicResponders,
        InjuriesPublic,
        OnsitePropertyDamage,
        OffsiteDeaths,
        Hospitalization,
        MedicalTreatment,
        Evacuated,
        ShelteredInPlace,
        OffsitePropertyDamage,
        ED_Kills,
        ED_MinorDefoliation,
        ED_WaterContamination,
        ED_SoilContamination,
        ED_Other,
        InitiatingEvent,
        CF_EquipmentFailure,
        CF_HumanError,
        CF_ImproperProcedure,
        CF_Overpressurization,
        CF_UpsetCondition,
        CF_BypassCondition,
        CF_Maintenance,
        CF_ProcessDesignFailure,
        CF_UnsuitableEquipment,
        CF_UnusualWeather,
        CF_ManagementError,
        CF_Other,
        OffsiteRespondersNotify,
        CI_ImprovedEquipment,
        CI_RevisedMaintenance,
        CI_RevisedTraining,
        CI_RevisedOpProcedures,
        CI_NewProcessControls,
        CI_NewMitigationSystems,
        CI_RevisedERPlan,
        CI_ChangedProcess,
        CI_ReducedInventory,
        CI_None,
        CI_OtherType,
        CBI_Flag
    FROM
        tblS6AccidentHistory a
        LEFT JOIN AccidentChemicalsByAccident ac
            ON a.AccidentHistoryID = ac.AccidentHistoryID
        LEFT JOIN SubmissionMeta s
            ON s.SubmissionID = a.FacilityID
    ORDER BY
        SubmissionID DESC,
        AccidentDate DESC,
        AccidentTime DESC,
        a.AccidentHistoryID DESC;


CREATE TEMPORARY VIEW AccidentDateLatestSubmissions AS
    SELECT
        a.EPAFacilityID,
        AccidentDate,
        MAX(ValidationDate),
        a.SubmissionID AS SubmissionIDLatest
    FROM
        AccidentEntries a
        LEFT JOIN SubmissionMeta s
            ON a.SubmissionID = s.SubmissionID
    GROUP BY
        a.EPAFacilityID,
        AccidentDate
;

CREATE TEMPORARY VIEW Accidents AS
    SELECT
        a.*
    FROM
        AccidentEntries a
        LEFT JOIN AccidentDateLatestSubmissions latest
            ON a.EPAFacilityID = latest.EPAFacilityID
            AND a.AccidentDate = latest.AccidentDate
    WHERE
        a.SubmissionID = latest.SubmissionIDLatest
    ORDER BY
        a.SubmissionID DESC,
        a.AccidentDate DESC,
        a.AccidentTime DESC,
        a.AccidentHistoryID DESC
;

-- ** Submission-level **

-- ProcessNAICSBySubmission
CREATE TEMPORARY VIEW ProcessNAICSBySubmission AS 
    SELECT
        SubmissionID,
        GROUP_CONCAT(NAICSCode, ' • ') AS NAICSCodes
    FROM (
        SELECT DISTINCT
            FacilityID AS SubmissionID,
            NAICSCode
        FROM
            tblS1Processes p
        LEFT JOIN tblS1Process_NAICS pn
            ON p.ProcessID = pn.ProcessID
        ORDER BY
            NAICSCode
    )
    GROUP BY
        SubmissionID
;

-- ProcessChemicalsBySubmission
CREATE TEMPORARY VIEW ProcessChemicalsBySubmission AS 
    SELECT
        SubmissionID,
        GROUP_CONCAT(
            ChemicalName || ' {' || CAST(Quantity AS INT) || '}',
            ' • '
        ) AS Chemicals
    FROM (
        SELECT
            p.FacilityID AS SubmissionID,
            ChemicalName,
            Quantity
        FROM
            tblS1Processes p
        LEFT JOIN tblS1ProcessChemicals pc
            ON p.ProcessID = pc.ProcessID
        LEFT JOIN tlkpChemicals lk
            ON pc.ChemicalID = lk.ChemicalID
        WHERE lk.ChemicalID != 0
        ORDER BY Quantity DESC,
            ChemicalName ASC
    )
    GROUP BY
        SubmissionID
;

-- AccidentChemicalsBySubmission
CREATE TEMPORARY VIEW AccidentChemicalsBySubmission AS 
    SELECT
        SubmissionID,
        GROUP_CONCAT(
            ChemicalName || ' {' || CAST(Quantity AS INT) || '}',
            ' • '
        ) AS AccidentChemicals
    FROM (
        SELECT * FROM AccidentChemicals
        ORDER BY
            Quantity DESC,
            ChemicalName ASC
    )
    GROUP BY
        SubmissionID;

-- AccidentsBySubmission
CREATE TEMPORARY VIEW AccidentsBySubmission AS
    SELECT
        FacilityID AS SubmissionID,
        COUNT(*) AS NumAccidents,
        SUBSTR(MAX(AccidentDate), 1, 10) AS LatestAccidentDate
    FROM
        tblS6AccidentHistory
    GROUP BY
        SubmissionID;

-- Submissions
CREATE TEMPORARY VIEW Submissions AS 
    SELECT
        s.SubmissionID,
        s.ReceiptDate,
        s.ValidationDate,
        s.DeregDate,
        s.DeregEffDate,
        s.SubType,
        lk.Description AS SubReason,
        s.EPAFacilityID,
        s.FacName,
        s.FacLat,
        s.FacLng,
        s.FRSLat,
        s.FRSLng,
        s.FacFTE,
        s.FacCompany1,
        s.FacCompany2,
        s.FacOperator,
        n.NAICSCodes,
        c.Chemicals,
        ac.AccidentChemicals,
        COALESCE(a.NumAccidents, 0) AS NumAccidents,
        a.LatestAccidentDate
    FROM
        SubmissionMeta s
        LEFT JOIN ProcessNAICSBySubmission n
            ON s.SubmissionID = n.SubmissionID
        LEFT JOIN ProcessChemicalsBySubmission c
            ON s.SubmissionID = c.SubmissionID
        LEFT JOIN AccidentsBySubmission a
            ON s.SubmissionID = a.SubmissionID
        LEFT JOIN AccidentChemicalsBySubmission ac
            ON s.SubmissionID = ac.SubmissionID
        LEFT JOIN tlkpSubmissionReasonCodes lk
            ON lk.LookupCode = s.SubReasonCode
    ORDER BY
        s.SubmissionID DESC;

-- ** Facility-level **

-- AccidentsByFacility
CREATE TEMPORARY VIEW AccidentsByFacility AS
    SELECT
        EPAFacilityID,
        COUNT(*) > 0 AS HasAccident,
        MAX(LatestAccidentDate) AS LatestAccidentDate
    FROM
        AccidentsBySubmission a
        LEFT JOIN SubmissionMeta s
            ON a.SubmissionID = s.SubmissionID
    GROUP BY
        EPAFacilityID;

-- SubmissionsByFacility
CREATE TEMPORARY VIEW SubmissionsByFacility AS
    SELECT
        EPAFacilityID,
        COUNT(*) AS NumSubmissions
    FROM
        Submissions
    GROUP BY
        EPAFacilityID;
        
-- LatestSubmissionsByFacility
CREATE TEMPORARY VIEW LatestSubmissionsByFacility AS
    SELECT
        SubmissionID,
        EPAFacilityID,
        FacCompany1,
        FacCompany2,
        FacOperator,
        FacLat,
        FacLng,
        MAX(ValidationDate) AS ValidationDate,
        ReceiptDate,
        DeregDate,
        DeregEffDate,
        NAICSCodes,
        Chemicals,
        NumAccidents,
        LatestAccidentDate,
        AccidentChemicals
    FROM
        Submissions
    GROUP BY
        EPAFacilityID;

-- Facilities
CREATE TEMPORARY VIEW Facilities AS
    SELECT
        ls.EPAFacilityID,
        m.FacName AS Name,
        m.FacCompany1 AS LatestCompany1,
        m.FacCompany2 AS LatestCompany2,
        m.FacOperator AS LatestOperator,
        m.Addr1,
        m.Addr2,
        m.City,
        m.State,
        m.ZipCode,
        m.CountyFIPS,
        m.FacLat AS Lat,
        m.FacLng AS Lng,
        NumSubmissions,
        m.ValidationDate AS LatestValidationDate,
        m.ReceiptDate AS LatestReceiptDate,
        m.DeregDate AS LatestDeregDate,
        m.DeregEffDate AS LatestDeregEffDate,
        NAICSCodes AS NAICSCodesInLatest,
        Chemicals AS ChemicalsInLatest,
        AccidentChemicals AS AccidentChemicalsInLatest,
        NumAccidents AS NumAccidentsInLatest
    FROM
        LatestSubmissionsByFacility ls
        LEFT JOIN SubmissionMeta m
            ON m.SubmissionID = ls.SubmissionID
        LEFT JOIN SubmissionsByFacility s
            ON s.EPAFacilityID = ls.EPAFacilityID
        LEFT JOIN AccidentsByFacility a
            ON a.EPAFacilityID = ls.EPAFacilityID;

