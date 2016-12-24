/* 
 * Filename:    Location.pde
 * Author:      Rish Vaishnav
 * Date:        12/22/2016
 *
 * Description:
 * This file contains the Location class. See class header for more
 * information.
 */

/**
 * A Location represents a two-dimensional location with an x- and
 * y-coordinate that can be displayed.
 */
class Location
{
    /* color of locations */
    private static final int LOC_COLOR = 200;

    /* size of locations */
    public static final float LOC_SIZE = 10;

    /* the x- and y-coordinates of this location */
    private double x = 0;
    private double y = 0;

    /**
     * Constructs a new location with the specified coordinates.
     *
     * @param init_x the initial x-coordinate
     * @param init_y the initial y-coordinate
     */
    public Location ( double init_x, double init_y ) {
        /* set the coordinates of this location */
        this.setCoordinates( init_x, init_y );
    }

    /**
     * Constructs a new location with the default coordinates of (0, 0).
     */
    public Location ()
    {
        /* set the coordinates of this location to the default coordinates
         * of (0, 0) */
        this.setCoordinates( 0, 0 );
    }

    /** 
     * Sets the coordinates of this location.
     *
     * @param new_x the new x-coordinate
     * @param new_y the new y-coordinate
     */
    public void setCoordinates ( double new_x, double new_y )
    {
        this.setX( new_x );
        this.setY( new_y );
    }

    /**
     * Sets the x-coordinate of this location.
     *
     * @param new_x the new x-coordinate
     */
    public void setX ( double new_x )
    {
        this.x = new_x;
    }

    /**
     * Sets the y-coordinate of this location.
     *
     * @param new_y the new y-coordinate
     */
    public void setY ( double new_y )
    {
        this.y = new_y;
    }

    /**
     * Returns the x-coordinate of this location.
     *
     * @return the x-coordinate of this location
     */
    public double getX ()
    {
        return this.x;
    }

    /**
     * Returns the y-coordinate of this location.
     *
     * @return the y-coordinate of this location
     */
    public double getY ()
    {
        return this.y;
    }

    /**
     * Returns whether or not this Location and another given Location are 
     * equal.
     *
     * @param loc the location to compare this one to
     *
     * @return is this location equal to the given location?
     */
    @Override
    public boolean equals ( Object loc )
    {
        /* the object types match */
        if  ( ( loc instanceof Location )
            && (this.getClass().equals( loc.getClass() ) ) )
        {
            /* the two locations are equivalent if they share the same x- and
             * y-coordinates */
            return ( this.getX() == ( ( Location ) loc ).getX() ) 
                && ( this.getY() == ( ( Location ) loc ).getY() );
        }

        return false;
    }

    /**
     * Redraws this location.
     */
    public void update () 
    {
        /* use black stroke */
        stroke( 0 );
        strokeWeight( 1 );

        /* reset color */
        fill( LOC_COLOR );

        /* redraw circle */
        ellipse( ( float ) ( this.getX() + TSPAlgorithms.ORIGIN_X ),
            ( float ) ( this.getY() + TSPAlgorithms.ORIGIN_Y ),
            LOC_SIZE, LOC_SIZE );
    }
}
