

START TRANSACTION;
DO
    $$BEGIN
        EXECUTE add_vol_engagement_func(
            10, '6981672', 'RUS',  CAST('15-jan-2019' AS DATE), CAST('20-jan-2019' AS DATE),
            7,
            'Anticorruption training - great lecture, slow to send expense report',
            700,
            5
        );
    END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
    $$BEGIN
        EXECUTE add_vol_engagement_func(
            10, '6981672', 'RUS',  CAST('11-oct-2018' AS DATE), CAST('31-oct-2018' AS DATE),
            9,
            'Anticorruption training - investigative reporting. Great work',
            700,
            10
        );
    END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
    $$BEGIN
        EXECUTE add_vol_engagement_func(
            9, '6681400', 'SRB,BIH',  CAST('1-Jan-2018' AS DATE), CAST('20-Feb-2018' AS DATE),
            9,
            'Legal education trainings in Balkans. Great as always!',
            900,
            20
        );
    END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
    $$BEGIN
        EXECUTE add_vol_engagement_func(
            14, '6981659', 'SOM',  CAST('11-oct-2018' AS DATE), CAST('31-oct-2018' AS DATE),
            7,
            'Justice sector training in Somalia. Pretty good job!',
            700,
            5
        );
    END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
    $$BEGIN
        EXECUTE add_paid_engagement_func(
            13, '6781505', 'MDA',  CAST('15-mar-2019' AS DATE), CAST('30-mar-2019' AS DATE),
            3,
            'Quality training but extremely difficult to work with.',
            1000,
            'Daily',
            7
        );
    END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
    $$BEGIN
        EXECUTE add_paid_engagement_func(
            14, '6991693', 'COD',  CAST('10-jun-2018' AS DATE), CAST('20-jul-2019' AS DATE),
            6,
            'Good job but very expensive.',
            1200,
            'Daily',
            7
        );
    END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
    $$BEGIN
        EXECUTE add_paid_engagement_func(
            15, '6781505', 'MDA',  CAST('11-oct-2017' AS DATE), CAST('18-oct-2017' AS DATE),
            7,
            'Good job - legal ed training',
            400,
            'Daily',
            7
        );
    END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
    $$BEGIN
        EXECUTE add_paid_engagement_func(
            15, '6781505', 'MDA',  CAST('18-oct-2017' AS DATE), CAST('30-oct-2017' AS DATE),
            8,
            'Legal Ed',
            400,
            'Daily',
            11
        );
    END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
    $$BEGIN
        EXECUTE add_paid_engagement_func(
            15, '6781505', 'MDA',  CAST('1-jan-2019' AS DATE), CAST('15-jan-2019' AS DATE),
            8,
            'Legal Ed',
            400,
            'Daily',
            11
        );
    END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
    $$BEGIN
        EXECUTE add_paid_engagement_func(
            9, '6681400', 'ALB,XKX,SRB,BIH',  CAST('1-jul-2016' AS DATE), CAST('15-aug-2016' AS DATE),
            6,
            'Legal Ed',
            400,
            'Daily',
            35
        );
    END$$;
COMMIT TRANSACTION;

START TRANSACTION;
DO
    $$BEGIN
        EXECUTE add_paid_engagement_func(
            9, '6781505', 'MDA',  CAST('1-DEC-2018' AS DATE), CAST('15-Dec-2018' AS DATE),
            7,
            'Trial advocacy trainings for defense attorneys',
            450,
            'Daily',
            10
        );
    END$$;
COMMIT TRANSACTION;













ROLLBACK TRANSACTION;