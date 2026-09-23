import { Router, type IRouter } from "express";
import healthRouter from "./health";
import likesRouter from "./likes";

const router: IRouter = Router();

router.use(healthRouter);
router.use(likesRouter);

export default router;
